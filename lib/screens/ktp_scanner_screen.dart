import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'vehicle_selection_screen.dart';

class KtpScannerScreen extends StatefulWidget {
  const KtpScannerScreen({super.key});

  @override
  State<KtpScannerScreen> createState() => _KtpScannerScreenState();
}

class _KtpScannerScreenState extends State<KtpScannerScreen> {
  bool _isScanning = false;
  String _statusText = 'Tempelkan E-KTP ke bagian belakang perangkat untuk membaca NFC.';

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _scanNfc() async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      _statusText = 'Mendeteksi NFC E-KTP...';
    });

    try {
      final NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        if (!mounted) {
          return;
        }

        final String availabilityMessage = availability == NFCAvailability.disabled
            ? 'NFC di perangkat ini sedang nonaktif. Aktifkan NFC di pengaturan lalu coba lagi.'
            : 'Perangkat ini tidak mendukung NFC. Gunakan ponsel fisik yang punya NFC.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(availabilityMessage)),
        );
        setState(() {
          _statusText = availabilityMessage;
        });
        return;
      }

      final dynamic tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
        androidCheckNDEF: false,
        androidPlatformSound: false,
        androidReaderModeFlags: 0x80 | 0x100,
        iosAlertMessage: 'Tempelkan E-KTP ke belakang perangkat',
      );

      if (!mounted) {
        return;
      }

      final String tagId = tag?.id?.toString() ?? '';
      setState(() {
        _statusText = tagId.isEmpty
            ? 'NFC E-KTP terbaca dengan sukses.'
            : 'NFC E-KTP terbaca: $tagId';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tagId.isEmpty
                ? 'NFC E-KTP terdeteksi'
                : 'NFC E-KTP terdeteksi: $tagId',
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VehicleSelectionScreen()),
      );
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Gagal membaca NFC E-KTP')),
      );
      setState(() {
        _statusText = 'NFC belum berhasil dibaca. Coba tempelkan kartu lagi.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC belum berhasil dibaca')),
      );
      setState(() {
        _statusText = 'NFC belum berhasil dibaca. Coba tempelkan kartu lagi.';
      });
    } finally {
      try {
        await FlutterNfcKit.finish(iosAlertMessage: 'Sesi NFC selesai');
      } catch (_) {
        // Abaikan bila sesi belum aktif atau sudah ditutup sistem.
      }

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = _isScanning;

    return Scaffold(
      backgroundColor: const Color(0xFF101214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101214),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan NFC E-KTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181B1F),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.nfc_rounded,
                          size: 54,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'NFC E-KTP',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 18),
                      if (isBusy)
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isBusy ? null : _scanNfc,
                  child: Text(isBusy ? 'Membaca NFC...' : 'Mulai Scan NFC'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tempelkan kartu ke area NFC perangkat. Kamera tidak digunakan pada layar ini.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}