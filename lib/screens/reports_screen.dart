import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';

import '../services/local_api_service.dart';
import '../models/device.dart';
import '../localization/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'report_devices_screen.dart';
import '../utils/web_download_stub.dart'
    if (dart.library.html) '../utils/web_download.dart' as web_download;

class ReportsScreen extends StatefulWidget {
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool loading = true;
  Map<String, int> stats = {};
  List<Device> _devices = [];
  String exportField = 'Status';
  String exportValue = 'All';

  @override
  void initState() {
    super.initState();
    load();
  }

  Map<String, int> locationStats = {};
  Map<String, int> typeStats = {};

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final devices = await context.read<ApiService>().getDevicesOnce();
      _devices = devices;

      stats = {
        'Total': devices.length,
        'New': devices.where((d) => d.status == 'New').length,
        'Good': devices.where((d) => d.status == 'Good').length,
        'Broken': devices.where((d) => d.status == 'Broken').length,
        'In Repair': devices.where((d) => d.status == 'In Repair').length,
      };

      locationStats = {};
      for (var device in devices) {
        locationStats[device.location] = (locationStats[device.location] ?? 0) + 1;
      }

      typeStats = {};
      for (var device in devices) {
        typeStats[device.type] = (typeStats[device.type] ?? 0) + 1;
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.read<LanguageProvider>().strings.errorPrefix}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<String> _exportValuesForField() {
    if (_devices.isEmpty) return const ['All'];
    switch (exportField) {
      case 'Location':
        return ['All', ..._devices.map((d) => d.location).toSet().toList()..sort()];
      case 'Type':
        return ['All', ..._devices.map((d) => d.type).toSet().toList()..sort()];
      case 'Status':
      default:
        return ['All', 'New', 'Good', 'Broken', 'In Repair'];
    }
  }

  List<Device> _filteredForExport() {
    if (exportValue == 'All') return _devices;
    switch (exportField) {
      case 'Location':
        return _devices.where((d) => d.location == exportValue).toList();
      case 'Type':
        return _devices.where((d) => d.type == exportValue).toList();
      case 'Status':
      default:
        return _devices.where((d) => d.status == exportValue).toList();
    }
  }

  List<Device> _devicesForStatus(String status) {
    return _devices.where((d) => d.status == status).toList();
  }

  List<Device> _devicesForLocation(String location) {
    return _devices.where((d) => d.location == location).toList();
  }

  List<Device> _devicesForType(String type) {
    return _devices.where((d) => d.type == type).toList();
  }

  String _exportValueLabel(String value, AppStrings strings) {
    if (value == 'All') return strings.exportAll;
    if (exportField == 'Status') return strings.statusValueLabel(value);
    if (exportField == 'Type') return strings.typeValueLabel(value);
    return value.isEmpty ? strings.unspecified : value;
  }

  Future<void> exportCSV() async {
    final strings = context.read<LanguageProvider>().strings;
    final rows = [
      [
        strings.idLabel,
        strings.nameDescriptionLabel,
        strings.typeLabel,
        strings.statusLabel,
        strings.locationLabel,
        strings.assignedToLabel,
      ],
      ..._filteredForExport().map((d) => [
            d.id,
            d.name,
            d.type,
            d.status,
            d.location,
            d.assignedTo,
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    if (kIsWeb) {
      final bytes = Uint8List.fromList(utf8.encode(csv));
      web_download.download(bytes, 'inventory_report.csv', 'text/csv');
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/inventory_report.csv');
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: strings.inventoryReport,
      ),
    );
  }

  Future<void> exportExcel() async {
    final strings = context.read<LanguageProvider>().strings;
    final excel = Excel.createExcel();
    final sheet = excel['Inventory'];
    sheet.appendRow([
      TextCellValue(strings.idLabel),
      TextCellValue(strings.nameDescriptionLabel),
      TextCellValue(strings.typeLabel),
      TextCellValue(strings.statusLabel),
      TextCellValue(strings.locationLabel),
      TextCellValue(strings.assignedToLabel),
    ]);
    for (final d in _filteredForExport()) {
      sheet.appendRow([
        TextCellValue(d.id),
        TextCellValue(d.name),
        TextCellValue(d.type),
        TextCellValue(d.status),
        TextCellValue(d.location),
        TextCellValue(d.assignedTo),
      ]);
    }
    final bytes = excel.encode();
    if (bytes == null) return;
    if (kIsWeb) {
      web_download.download(
        Uint8List.fromList(bytes),
        'inventory_report.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/inventory_report.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: strings.inventoryReport,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportsAndStats),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: load),
          if (role == 'admin') ...[
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _devices.isEmpty ? null : exportCSV,
            ),
            IconButton(
              icon: const Icon(Icons.table_view),
              onPressed: _devices.isEmpty ? null : exportExcel,
            ),
          ],
        ],
      ),
      body: role != 'admin'
          ? Center(child: Text(strings.adminAccessRequired))
          : loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Text(strings.exportBy),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: exportField,
                          items: [
                            DropdownMenuItem(
                              value: 'Status',
                              child: Text(strings.exportFieldStatus),
                            ),
                            DropdownMenuItem(
                              value: 'Location',
                              child: Text(strings.exportFieldLocation),
                            ),
                            DropdownMenuItem(
                              value: 'Type',
                              child: Text(strings.exportFieldType),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              exportField = v;
                              exportValue = 'All';
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: exportValue,
                          items: _exportValuesForField()
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(_exportValueLabel(v, strings)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => exportValue = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    tabs: [
                      Tab(text: strings.tabByStatus),
                      Tab(text: strings.tabByLocation),
                      Tab(text: strings.tabByType),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: stats.entries
                                .where((e) => e.key != 'Total')
                                .map(
                                  (e) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(strings.statusValueLabel(e.key)),
                                      trailing: Text(
                                        '${e.value}',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      onTap: () {
                                        final devices = _devicesForStatus(e.key);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReportDevicesScreen(
                                              title:
                                                  '${strings.exportFieldStatus}: ${strings.statusValueLabel(e.key)}',
                                              devices: devices,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: locationStats.entries
                                .map(
                                  (e) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(
                                        e.key.isEmpty ? strings.unspecified : e.key,
                                      ),
                                      trailing: Text(
                                        '${e.value}',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      onTap: () {
                                        final key = e.key;
                                        final devices = _devicesForLocation(key);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReportDevicesScreen(
                                              title:
                                                  '${strings.exportFieldLocation}: ${key.isEmpty ? strings.unspecified : key}',
                                              devices: devices,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: typeStats.entries
                                .map(
                                  (e) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(e.key),
                                      trailing: Text(
                                        '${e.value}',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      onTap: () {
                                        final devices = _devicesForType(e.key);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReportDevicesScreen(
                                              title:
                                                  '${strings.exportFieldType}: ${strings.typeValueLabel(e.key)}',
                                              devices: devices,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
