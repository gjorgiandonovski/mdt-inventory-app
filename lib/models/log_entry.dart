import 'package:cloud_firestore/cloud_firestore.dart';

class LogEntry {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String actorId;
  final String actorEmail;
  final DateTime createdAt;
  final Map<String, dynamic>? details;

  LogEntry({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.actorId,
    required this.actorEmail,
    required this.createdAt,
    this.details,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final raw = json['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return LogEntry(
      id: (json['id'] ?? '') as String,
      action: (json['action'] ?? '') as String,
      entityType: (json['entityType'] ?? '') as String,
      entityId: (json['entityId'] ?? '') as String,
      actorId: (json['actorId'] ?? '') as String,
      actorEmail: (json['actorEmail'] ?? '') as String,
      createdAt: createdAt,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
