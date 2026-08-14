import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../app_session.dart';
import '../cashier/cashier_buyer_repository.dart';
import '../models/cashier_buyer_lookup.dart';
import 'transaction_input_screen.dart';

class KtpScannerScreen extends StatefulWidget {
  const KtpScannerScreen({super.key});

  @override
  State<KtpScannerScreen> createState() => _KtpScannerScreenState();
}

class _KtpScannerScreenState extends State<KtpScannerScreen> {
  final CashierBuyerRepository _buyerRepository = CashierBuyerRepository();
  bool _isScanning = false;
  String _statusText =
      'Tempelkan E-KTP ke bagian belakang perangkat untuk membaca NFC.';

  String _maskNfcValue(String value) {
    if (value.length <= 4) {
      return value;
    }

    return '${'•' * (value.length - 4)}${value.substring(value.length - 4)}';
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

        final String availabilityMessage =
            availability == NFCAvailability.disabled
            ? 'NFC di perangkat ini sedang nonaktif. Aktifkan NFC di pengaturan lalu coba lagi.'
            : 'Perangkat ini tidak mendukung NFC. Gunakan ponsel fisik yang punya NFC.';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(availabilityMessage)));
        setState(() {
          _statusText = availabilityMessage;
        });
        return;
      }

      final dynamic tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
        androidCheckNDEF: false,
        androidPlatformSound: false,
        androidReaderModeFlags: 0x1F | 0x80 | 0x100,
        iosAlertMessage: 'Tempelkan E-KTP ke belakang perangkat',
      );

      if (!mounted) {
        return;
      }

      final String tagId = tag?.id?.toString() ?? '';
      final String maskedTagId = tagId.isEmpty ? '' : _maskNfcValue(tagId);
      if (tagId.isEmpty) {
        throw Exception('Serial number NFC tidak ditemukan dari E-KTP.');
      }

      setState(() {
        _statusText = maskedTagId.isEmpty
            ? 'NFC E-KTP terbaca dengan sukses.'
            : 'NFC E-KTP terbaca: $maskedTagId';
      });

      final lookupResult = await _buyerRepository.lookupBuyerByNfc(tagId);
      if (!mounted) {
        return;
      }

      SessionScope.of(context).bumpCashierDataRevision();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            maskedTagId.isEmpty
                ? 'NFC E-KTP terdeteksi'
                : 'NFC E-KTP terdeteksi: $maskedTagId',
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionInputScreen(
            vehicle: CashierVehicleInfo.fromPersonalBuyer(lookupResult.buyer),
            buyerName: lookupResult.buyer.name,
            buyerNik: lookupResult.buyer.nikSnapshot,
            isPinActive: lookupResult.buyer.isPinActive,
            buyer: lookupResult.buyer,
          ),
        ),
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
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().replaceFirst('Exception: ', '');
      SessionScope.of(context).bumpCashierDataRevision();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _statusText = message;
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
        // Ignore if the session is already closed.
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
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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
