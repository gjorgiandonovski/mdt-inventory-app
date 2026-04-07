import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_item.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/local_api_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final api = context.read<ApiService>();
    final strings = context.watch<LanguageProvider>().strings;
    final userId = auth.user?['uid'] as String?;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text(strings.signInRequiredNotifications)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.notifications)),
      body: StreamBuilder<List<NotificationItem>>(
        stream: api.streamNotificationsForUser(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(child: Text(strings.noNotificationsYet));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text('${item.message}\n${_formatDate(item.createdAt)}'),
                  isThreeLine: true,
                  trailing: item.read
                      ? const Icon(Icons.mark_email_read, color: Colors.grey)
                      : const Icon(Icons.mark_email_unread, color: Colors.blue),
                  onTap: item.read
                      ? null
                      : () => api.markNotificationRead(userId, item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
