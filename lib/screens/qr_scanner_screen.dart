import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/theme.dart';
import 'vehicle_selection_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101214),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_hasScanned) return;
              final Barcode barcode = capture.barcodes.first;
              final String? rawValue = barcode.rawValue;
              if (rawValue == null || rawValue.isEmpty) return;
              _hasScanned = true;
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR terdeteksi. Memuat data...')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const VehicleSelectionScreen(),
                ),
              );
            },
          ),
          const _ScannerOverlay(),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Text(
              'Arahkan QR Code Pengguna ke dalam area ini',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScannerOverlayPainter(),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final Paint clearPaint = Paint()..blendMode = BlendMode.clear;

    final double frameSize = 240;
    final RRect hole = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 20),
        width: frameSize,
        height: frameSize,
      ),
      const Radius.circular(16),
    );

    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, overlayPaint);
    canvas.drawRRect(hole, clearPaint);
    canvas.restore();

    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(hole, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
