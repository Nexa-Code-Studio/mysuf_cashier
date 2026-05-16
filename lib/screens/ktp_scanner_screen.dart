import 'package:flutter/material.dart';
import '../widgets/scanner_frame.dart';
import 'vehicle_selection_screen.dart';

class KtpScannerScreen extends StatelessWidget {
  const KtpScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101214),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ScannerFrame(
        helperText:
            'Arahkan Kamera ke E-KTP atau Tempelkan E-KTP (NFC) ke belakang perangkat',
        buttonLabel: 'Simulasikan Berhasil',
        onSimulate: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VehicleSelectionScreen()),
          );
        },
      ),
    );
  }
}
