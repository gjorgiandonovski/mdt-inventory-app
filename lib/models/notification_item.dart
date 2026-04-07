import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String? issueId;
  final String? deviceId;
  final bool read;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.issueId,
    this.deviceId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final raw = json['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return NotificationItem(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      issueId: json['issueId'] as String?,
      deviceId: json['deviceId'] as String?,
      read: (json['read'] ?? false) as bool,
      createdAt: createdAt,
    );
  }
}
