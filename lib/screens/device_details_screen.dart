import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../models/issue.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/local_api_service.dart';

import 'add_device_screen.dart';
import 'report_issue_screen.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final String deviceId;
  const DeviceDetailsScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    final role = context.watch<AuthProvider>().role;
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.deviceDetailsTitle)),
      body: StreamBuilder<Device?>(
        stream: api.streamDevice(deviceId),
        builder: (_, snap) {
          if (snap.hasError) {
            return Center(child: Text('${strings.errorPrefix}: ${snap.error}'));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final device = snap.data;
          if (device == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(strings.deviceNotFound,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  if (role != 'viewer')
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddDeviceScreen(deviceId: deviceId),
                        ),
                      ),
                      child: Text(strings.addNewDeviceTitle),
                    ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (device.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(device.imageUrl!, height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(device.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),

              _row(strings.idLabel, device.id),
              _row(strings.typeLabel, strings.typeValueLabel(device.type)),
              _row(strings.brandModelLabel, '${device.brand} ${device.model}'.trim()),
              _row(strings.locationLabel, device.location),
              _row(strings.assignedToLabel, device.assignedTo),
              _row(strings.statusLabel, strings.statusValueLabel(device.status)),
              if (device.notes.trim().isNotEmpty) _row(strings.notesLabel, device.notes),

              const SizedBox(height: 16),

              if (role == 'staff')
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportIssueScreen(
                        deviceId: deviceId,
                        deviceLocation: device.location,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.warning),
                  label: Text(strings.reportIssueButton),
                ),

              const SizedBox(height: 16),

              if (role == 'admin' || role == 'staff')
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddDeviceScreen(
                        deviceId: device.id,
                        existingDevice: device,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                  label: Text(strings.editDeviceTitle),
                ),

              const SizedBox(height: 8),

              if (role == 'admin')
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(strings.deleteDeviceTitle),
                        content: Text(strings.deleteDeviceConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(strings.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await api.deleteDevice(device.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: Text(strings.deleteDeviceTitle),
                ),

              const SizedBox(height: 24),
              Text(strings.issuesTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),

              StreamBuilder<List<Issue>>(
                stream: api.streamIssuesForDevice(deviceId),
                builder: (_, issuesSnap) {
                  if (issuesSnap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('${strings.errorPrefix}: ${issuesSnap.error}'),
                    );
                  }
                  if (!issuesSnap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final issues = issuesSnap.data!;
                  if (issues.isEmpty) return Text(strings.issuesEmpty);

                  return Column(
                    children: issues.map((iss) {
                      return Card(
                        child: ListTile(
                          title: Text(iss.description),
                          subtitle: Text(
                            '${strings.issueStatusLabel(iss.status)}${iss.assignedTo != null ? ' • ${strings.assignedToLabel}: ${iss.assignedTo}' : ''} • ${iss.location} • ${_formatDate(iss.createdAt)}',
                          ),
                          trailing: role == 'admin'
                              ? PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    String? assignedTo;
                                    if (v == 'In Progress' || v == 'Fixed') {
                                      assignedTo = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) {
                                          final controller = TextEditingController();
                                          return AlertDialog(
                                            title: Text(strings.assignToTechnician),
                                            content: TextField(
                                              controller: controller,
                                              decoration: InputDecoration(
                                                labelText: strings.technicianLabel,
                                                hintText: strings.technicianHint,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: Text(strings.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  ctx,
                                                  controller.text.trim().isEmpty
                                                      ? null
                                                      : controller.text.trim(),
                                                ),
                                                child: Text(strings.assign),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    await api.updateIssueStatus(
                                      iss.id,
                                      v,
                                      strings: strings,
                                      assignedTo: assignedTo,
                                    );
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'Pending',
                                      child: Text(strings.issueStatusLabel('Pending')),
                                    ),
                                    PopupMenuItem(
                                      value: 'In Progress',
                                      child: Text(strings.issueStatusLabel('In Progress')),
                                    ),
                                    PopupMenuItem(
                                      value: 'Fixed',
                                      child: Text(strings.issueStatusLabel('Fixed')),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text('$k:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
