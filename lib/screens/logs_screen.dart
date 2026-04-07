import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/log_entry.dart';
import '../providers/language_provider.dart';
import '../services/local_api_service.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.adminLogs)),
      body: StreamBuilder<List<LogEntry>>(
        stream: api.streamLogs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return Center(child: Text(strings.noLogsYet));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                child: ListTile(
                  title: Text(strings.logActionLabel(log.action)),
                  subtitle: Text(
                    '${strings.logEntityLabel}: ${strings.entityLabel(log.entityType)} ${log.entityId}\n${strings.logActorLabel}: ${log.actorEmail}\n${_formatDate(log.createdAt)}',
                  ),
                  isThreeLine: true,
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
