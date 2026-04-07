import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../localization/app_strings.dart';
import '../models/device.dart';
import '../models/issue.dart';
import '../models/log_entry.dart';
import '../models/notification_item.dart';
import '../providers/auth_provider.dart' as app_auth;

class ApiService {
  final app_auth.AuthProvider auth;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  ApiService(this.auth);

  Stream<List<Device>> streamDevices({String? status}) {
    Query<Map<String, dynamic>> query = _db.collection('devices');
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        return Device.fromJson(data);
      }).toList();
    });
  }


  Stream<Device?> streamDevice(String id) {
    return _db.collection('devices').doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() ?? {};
      data['id'] ??= doc.id;
      return Device.fromJson(data);
    });
  }

  Future<List<Device>> getDevicesOnce() async {
    final snap = await _db.collection('devices').get();
    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] ??= doc.id;
      return Device.fromJson(data);
    }).toList();
  }

  Future<Device?> getDeviceOnce(String id) async {
    final doc = await _db.collection('devices').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    data['id'] ??= doc.id;
    return Device.fromJson(data);
  }

  Future<void> addOrUpdateDevice(Device device) async {
    final data = device.toJson();
    final docRef = _db.collection('devices').doc(device.id);
    final existing = await docRef.get();
    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data, SetOptions(merge: true));

    await _logAction(
      action: existing.exists ? 'device_updated' : 'device_created',
      entityType: 'device',
      entityId: device.id,
      details: {
        'name': device.name,
        'type': device.type,
        'status': device.status,
      },
    );
  }

  Future<String> uploadImageData({
    required String folder,
    required Uint8List data,
    String? extension,
    String? contentType,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = (extension != null && extension.trim().isNotEmpty)
        ? extension.trim()
        : 'jpg';
    final ref = _storage.ref().child('$folder/$uid/$timestamp.$ext');
    final metadata = contentType == null
        ? null
        : SettableMetadata(contentType: contentType);
    final task = await ref.putData(data, metadata);
    return await task.ref.getDownloadURL();
  }

  Stream<List<Issue>> streamIssuesForDevice(String deviceId) {
    return _db
        .collection('issues')
        .where('deviceId', isEqualTo: deviceId)
        .snapshots()
        .map((snap) {
      final issues = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        return Issue.fromJson(data);
      }).toList();
      issues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return issues;
    });
  }

  Stream<List<Map<String, dynamic>>> streamUsers() {
    return _db.collection('users').orderBy('email').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _db.collection('users').doc(userId).set(
      {
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await _logAction(
      action: 'user_role_updated',
      entityType: 'user',
      entityId: userId,
      details: {'role': role},
    );
  }

  Future<void> reportIssue({
    required String deviceId,
    required String description,
    required String location,
    required AppStrings strings,
    String? imageUrl,
  }) async {
    final reporterId = auth.user?['uid'] as String? ?? 'unknown';

    final issueData = {
      'deviceId': deviceId,
      'description': description,
      'status': 'Pending',
      'reporterId': reporterId,
      'assignedTo': null,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final issueRef = await _db.collection('issues').add(issueData);

    await _db.collection('devices').doc(deviceId).set({
      'status': 'Broken',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _notifyAdmins(
      title: strings.issueReportedTitle,
      message: strings.issueReportedMessage(deviceId, description),
      issueId: issueRef.id,
      deviceId: deviceId,
    );

    await _logAction(
      action: 'issue_reported',
      entityType: 'issue',
      entityId: issueRef.id,
      details: {
        'deviceId': deviceId,
        'description': description,
      },
    );
  }


  Future<void> updateIssueStatus(
    String issueId,
    String newStatus, {
    required AppStrings strings,
    String? assignedTo,
  }) async {
    final docRef = _db.collection('issues').doc(issueId);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final data = snap.data() ?? {};

    final update = <String, dynamic>{
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (assignedTo != null) {
      update['assignedTo'] = assignedTo;
    }

    await docRef.update(update);

    final reporterId = data['reporterId'] as String?;
    final deviceId = data['deviceId'] as String? ?? '';
    if (reporterId != null && reporterId.isNotEmpty) {
      await _createNotification(
        userId: reporterId,
        title: strings.issueUpdatedTitle,
        message: strings.issueUpdatedMessage(
          deviceId,
          strings.issueStatusLabel(newStatus),
        ),
        issueId: issueId,
        deviceId: deviceId,
      );
    }
    if (assignedTo != null && assignedTo.trim().isNotEmpty) {
      await _notifyAssigneeByEmail(
        email: assignedTo.trim(),
        title: strings.issueAssignedTitle,
        message: strings.issueAssignedMessage(issueId, deviceId),
        issueId: issueId,
        deviceId: deviceId,
      );
    }

    await _logAction(
      action: 'issue_status_updated',
      entityType: 'issue',
      entityId: issueId,
      details: {
        'status': newStatus,
        'assignedTo': assignedTo,
      },
    );
  }

  Future<void> deleteDevice(String id) async {
    await _db.collection('devices').doc(id).delete();
    await _logAction(
      action: 'device_deleted',
      entityType: 'device',
      entityId: id,
    );
  }

  Stream<List<NotificationItem>> streamNotificationsForUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        return NotificationItem.fromJson(data);
      }).toList();
    });
  }

  Future<void> markNotificationRead(String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Stream<List<LogEntry>> streamLogs() {
    return _db
        .collection('logs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        return LogEntry.fromJson(data);
      }).toList();
    });
  }

  Future<void> _notifyAdmins({
    required String title,
    required String message,
    required String issueId,
    required String deviceId,
  }) async {
    final admins = await _db.collection('users').where('role', isEqualTo: 'admin').get();
    for (final admin in admins.docs) {
      await _createNotification(
        userId: admin.id,
        title: title,
        message: message,
        issueId: issueId,
        deviceId: deviceId,
      );
    }
  }

  Future<void> _notifyAssigneeByEmail({
    required String email,
    required String title,
    required String message,
    required String issueId,
    required String deviceId,
  }) async {
    final users = await _db.collection('users').where('email', isEqualTo: email).get();
    for (final user in users.docs) {
      await _createNotification(
        userId: user.id,
        title: title,
        message: message,
        issueId: issueId,
        deviceId: deviceId,
      );
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    String? issueId,
    String? deviceId,
  }) async {
    await _db.collection('users').doc(userId).collection('notifications').add({
      'title': title,
      'message': message,
      'issueId': issueId,
      'deviceId': deviceId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _logAction({
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? details,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await _db.collection('logs').add({
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'details': details,
      'actorId': currentUser?.uid ?? 'unknown',
      'actorEmail': currentUser?.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
