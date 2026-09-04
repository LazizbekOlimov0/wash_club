import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/theme/extensions/theme_extension.dart';

/// Darvoza/boks ustidagi QR kodni skanerlash uchun to'liq ekranli sahifa.
/// Skanerlanganda `Navigator.pop(context, rawValue)` orqali kod matnini qaytaradi.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _handled = false;

  bool get _isSupported => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    if (_isSupported) {
      _controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    Navigator.pop(context, raw);
  }

  Widget _buildPermissionError(BuildContext context, MobileScannerException error) {
    final t = context.t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            Text(
              t.qrScan.cameraPermission,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.qrScan.cameraPermissionDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupported(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.qr_code_scanner, color: colors.grey2, size: 64),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                t.qrScan.unsupported,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onBackground,
                    side: BorderSide(color: colors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    t.qrScan.cancel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;

    if (!_isSupported) {
      return _buildUnsupported(context);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller!,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _buildPermissionError(context, error),
            ),
          ),
          // Orqaga qaytish tugmasi
          Positioned(
            top: 48,
            left: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.4),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: t.qrScan.cancel,
              ),
            ),
          ),
          // Skanerlash ramkasi (viewfinder)
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: colors.primary, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Yuqori sarlavha
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  t.qrScan.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.qrScan.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Pastki bekor qilish tugmasi
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  t.qrScan.cancel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
