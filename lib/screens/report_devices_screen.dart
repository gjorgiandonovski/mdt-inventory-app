import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../providers/language_provider.dart';
import 'device_details_screen.dart';

class ReportDevicesScreen extends StatelessWidget {
  final String title;
  final List<Device> devices;

  const ReportDevicesScreen({
    super.key,
    required this.title,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: devices.isEmpty
          ? Center(child: Text(strings.noDevicesFoundShort))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final device = devices[index];
                return Card(
                  child: ListTile(
                    title: Text(device.name),
                    subtitle: Text(
                      '${strings.typeValueLabel(device.type)} • ${device.location}',
                    ),
                    trailing: Text(strings.statusValueLabel(device.status)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeviceDetailsScreen(deviceId: device.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
