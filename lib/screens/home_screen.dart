import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/local_api_service.dart';
import 'scan_screen.dart';
import 'reports_screen.dart';
import 'device_details_screen.dart';
import 'add_device_screen.dart';
import 'notifications_screen.dart';
import 'logs_screen.dart';
import 'users_admin_screen.dart';
import 'ai_assistant_screen.dart';
import '../models/device.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedStatus;

  Future<String?> _promptForDeviceId() async {
    String deviceIdInput = '';
    String? result;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final strings = context.watch<LanguageProvider>().strings;
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(strings.addDeviceTitle),
              content: TextField(
                decoration: InputDecoration(
                  labelText: strings.deviceIdLabel,
                  hintText: strings.deviceIdHint,
                  errorText: errorText,
                ),
                textInputAction: TextInputAction.done,
                onChanged: (value) => deviceIdInput = value,
                onSubmitted: (_) {
                  final value = deviceIdInput.trim();
                  if (value.isEmpty) {
                    setState(() => errorText = strings.deviceIdRequired);
                    return;
                  }
                  result = value;
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(strings.cancel),
                ),
                TextButton(
                  onPressed: () {
                    final value = deviceIdInput.trim();
                    if (value.isEmpty) {
                      setState(() => errorText = strings.deviceIdRequired);
                      return;
                    }
                    result = value;
                    Navigator.pop(context);
                  },
                  child: Text(strings.continueLabel),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final api = context.read<ApiService>();
    final strings = context.watch<LanguageProvider>().strings;

    if (auth.user == null || auth.role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isViewer = auth.role == 'viewer';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          strings.appTitle,
          style: const TextStyle(
            color: Color(0xFF702673),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          if (auth.role == 'admin')
            IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogsScreen()),
              ),
            ),
          if (auth.role == 'admin')
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersAdminScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ScanScreen()),
                        ),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(strings.scanQr),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: auth.role == 'admin'
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ReportsScreen()),
                                )
                            : null,
                        icon: const Icon(Icons.assessment),
                        label: Text(strings.reports),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isViewer
                        ? null
                        : () async {
                            final id = await _promptForDeviceId();
                            if (id == null || !mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddDeviceScreen(deviceId: id),
                              ),
                            );
                          },
                    icon: const Icon(Icons.add),
                    label: Text(strings.addDeviceButton),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                    ),
                    icon: const Icon(Icons.smart_toy),
                    label: Text(strings.aiAssistantButton),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<List<Device>>(
              stream: api.streamDevices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final devices = snapshot.data!;
                final statuses = ['All', 'New', 'Good', 'Broken', 'In Repair'];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((status) {
                      final count = status == 'All'
                          ? devices.length
                          : devices.where((d) => d.status == status).length;
                      final isSelected = (status == 'All' && _selectedStatus == null) ||
                          _selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            '${status == 'All' ? strings.exportAll : strings.statusValueLabel(status)} ($count)',
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedStatus = status == 'All' ? null : status;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Device>>(
              stream: api.streamDevices(status: _selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${strings.errorPrefix}: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(strings.noDevicesFound),
                  );
                }

                final devices = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: device.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  device.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.devices, size: 40),
                        title: Text(device.name),
                        subtitle: Text(
                          '${strings.typeValueLabel(device.type)} • ${device.location}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(device.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                strings.statusValueLabel(device.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeviceDetailsScreen(deviceId: device.id),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    const primary = Color(0xFF702673);
    switch (status) {
      case 'New':
        return primary.withValues(alpha: 0.9);
      case 'Good':
        return Colors.green.shade700;
      case 'Broken':
        return Colors.red.shade700;
      case 'In Repair':
        return Colors.orange.shade700;
      default:
        return primary.withValues(alpha: 0.6);
    }
  }
}
