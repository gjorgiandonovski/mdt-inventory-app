import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../services/local_api_service.dart';
import 'device_details_screen.dart';
import 'add_device_screen.dart';

class ScanScreen extends StatefulWidget {
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _navigated = false;
  bool _isShowingError = false;
  final MobileScannerController _controller = MobileScannerController();

  String? _normalizeDeviceId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      final fromQuery = uri.queryParameters['deviceId'] ?? uri.queryParameters['id'];
      if (fromQuery != null && fromQuery.trim().isNotEmpty) {
        return fromQuery.trim();
      }
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
    }

    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.scanQrTitle)),
      body: MobileScanner(
        controller: _controller,
        errorBuilder: (context, error) {
          final isPermission = error.errorCode == MobileScannerErrorCode.permissionDenied;
          final message = isPermission
              ? strings.cameraPermissionDenied
              : strings.cameraError(error.errorCode.message);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        overlayBuilder: (context, constraints) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                strings.scanInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        onDetect: (capture) async {
          if (_navigated || _isShowingError) return;
          final raw = capture.barcodes.first.rawValue;
          if (raw == null || raw.trim().isEmpty) return;
          final id = _normalizeDeviceId(raw);
          if (id == null || id.isEmpty || id.contains('/')) {
            _isShowingError = true;
            _controller.stop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.invalidQrCode)),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              _isShowingError = false;
              _controller.start();
            });
            return;
          }

          _navigated = true;
          _controller.stop();
          final api = context.read<ApiService>();
          try {
            final device = await api
                .getDeviceOnce(id.trim())
                .timeout(const Duration(seconds: 5));
            final target = device == null
                ? AddDeviceScreen(deviceId: id.trim())
                : DeviceDetailsScreen(deviceId: id.trim());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => target),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${strings.lookupFailedPrefix}: $e')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AddDeviceScreen(deviceId: id.trim())),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
