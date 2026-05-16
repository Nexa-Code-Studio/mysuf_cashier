import 'package:flutter/material.dart';
import '../widgets/scanner_frame.dart';
import 'vehicle_selection_screen.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101214),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ScannerFrame(
        helperText: 'Arahkan QR Code Pengguna ke area ini',
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
