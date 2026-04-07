import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String id;
  final String deviceId;
  final String description;
  final String status;
  final String reporterId;
  final String? assignedTo;
  final String? imageUrl;
  final String location;
  final DateTime createdAt;

  Issue({
    required this.id,
    required this.deviceId,
    required this.description,
    required this.status,
    required this.reporterId,
    required this.createdAt,
    required this.location,
    this.assignedTo,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'description': description,
    'status': status,
    'reporterId': reporterId,
    'assignedTo': assignedTo,
    'imageUrl': imageUrl,
    'location': location,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Issue.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final raw = json['createdAt'];
    if (raw is String) {
      createdAt = DateTime.parse(raw);
    } else if (raw is DateTime) {
      createdAt = raw;
    } else if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else {
      createdAt = DateTime.now();
    }
    return Issue(
      id: json['id'] as String? ?? '',
      deviceId: (json['deviceId'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      status: (json['status'] ?? 'Pending') as String,
      reporterId: (json['reporterId'] ?? '') as String,
      assignedTo: json['assignedTo'] as String?,
      imageUrl: json['imageUrl'] as String?,
      location: (json['location'] ?? '') as String,
      createdAt: createdAt,
    );
  }
}
