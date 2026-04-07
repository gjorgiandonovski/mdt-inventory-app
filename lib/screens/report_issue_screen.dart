import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/local_api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class ReportIssueScreen extends StatefulWidget {
  final String deviceId;
  final String? deviceLocation;
  const ReportIssueScreen({super.key, required this.deviceId, this.deviceLocation});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.deviceLocation != null) {
      _locationController.text = widget.deviceLocation!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = context.read<LanguageProvider>().strings;
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.reportDescriptionRequired)),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.reportLocationRequired)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final strings = context.read<LanguageProvider>().strings;
      await context.read<ApiService>().reportIssue(
        deviceId: widget.deviceId,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        strings: strings,
        imageUrl: null,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.reportSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.reportFailedPrefix}: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final strings = context.watch<LanguageProvider>().strings;
    if (role != 'staff') {
      return Scaffold(
        body: Center(child: Text(strings.onlyStaffCanReport)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(strings.reportIssue)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '${strings.deviceIdLabel}: ${widget.deviceId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: strings.issueDescriptionLabel,
                hintText: strings.issueDescriptionHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: strings.locationLabel,
                hintText: strings.locationHint,
                border: const OutlineInputBorder(),
              ),
              enabled: widget.deviceLocation == null,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(strings.submitReport),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
