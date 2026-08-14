import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:subsidia_cashier/core/constants/app_constants.dart';
import 'package:subsidia_cashier/utils/qr_payload_decoder.dart';

void main() {
  test('decodes SUBSIDIA warga QR payload into NIK', () {
    const nik = '3201010101010001';
    final rawBytes = utf8.encode(nik);
    final keyBytes = utf8.encode(AppConstants.qrisSecretKey);
    final xorBytes = List<int>.generate(
      rawBytes.length,
      (index) => rawBytes[index] ^ keyBytes[index % keyBytes.length],
    );
    final qrData = 'SUBSIDIA-QRIS:KTP:${base64.encode(xorBytes)}';

    expect(QrPayloadDecoder.decodeOrRaw(qrData), nik);
  });

  test('returns raw value when payload is not SUBSIDIA QR format', () {
    expect(
      QrPayloadDecoder.decodeOrRaw('  3201010101010001  '),
      '3201010101010001',
    );
  });
}