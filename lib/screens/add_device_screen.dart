import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../services/local_api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  final String deviceId;
  final Device? existingDevice;
  const AddDeviceScreen({super.key, required this.deviceId, this.existingDevice});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _locationController = TextEditingController();
  final _assignedController = TextEditingController();
  final _notesController = TextEditingController();

  String type = 'Laptop';
  String status = 'Good';
  bool loading = false;

  final types = const ['Laptop', 'Printer', 'Monitor', 'Tool', 'Phone', 'Tablet', 'Other'];
  final statuses = const ['New', 'Good', 'Broken', 'In Repair'];

  @override
  void initState() {
    super.initState();
    if (widget.existingDevice != null) {
      final d = widget.existingDevice!;
      _nameController.text = d.name;
      _brandController.text = d.brand;
      _modelController.text = d.model;
      _locationController.text = d.location;
      _assignedController.text = d.assignedTo;
      _notesController.text = d.notes;
      type = d.type;
      status = d.status;
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final device = Device(
        id: widget.deviceId,
        name: _nameController.text.trim(),
        type: type,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        location: _locationController.text.trim(),
        assignedTo: _assignedController.text.trim(),
        status: status,
        notes: _notesController.text.trim(),
        imageUrl: null,
      );

      await context.read<ApiService>().addOrUpdateDevice(device);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().strings.deviceSavedSuccess,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.read<LanguageProvider>().strings.deviceSaveFailedPrefix}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingDevice != null;
    final role = context.watch<AuthProvider>().role;
    final strings = context.watch<LanguageProvider>().strings;
    final isStaff = role == 'staff';

    final canEditAll = role == 'admin' || !isEdit;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? strings.editDeviceTitle : strings.addNewDeviceTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('${strings.deviceIdLabel}: ${widget.deviceId}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (isEdit)
                Text(
                  strings.readOnlyNote,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: strings.nameDescriptionLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? strings.requiredField : null,
                enabled: canEditAll,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: strings.typeCategoryLabel),
                items: types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(strings.typeValueLabel(t)),
                      ),
                    )
                    .toList(),
                onChanged: canEditAll ? (v) => setState(() => type = v ?? type) : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: strings.brandLabel),
                enabled: canEditAll,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: strings.modelLabel),
                enabled: canEditAll,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: strings.locationOfficeLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? strings.requiredField : null,
                enabled: canEditAll,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _assignedController,
                decoration: InputDecoration(labelText: strings.assignedToLabel),
                enabled: canEditAll || isStaff,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(labelText: strings.conditionLabel),
                items: statuses
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(strings.statusValueLabel(s)),
                      ),
                    )
                    .toList(),
                onChanged: (canEditAll || isStaff)
                    ? (v) => setState(() => status = v ?? status)
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: strings.notesLabel),
                maxLines: 3,
                enabled: canEditAll,
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : save,
                  child: loading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(isEdit ? strings.updateDevice : strings.saveDevice),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
