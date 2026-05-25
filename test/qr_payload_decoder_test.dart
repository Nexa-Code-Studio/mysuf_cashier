import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysuf_cashier/core/constants/app_constants.dart';
import 'package:mysuf_cashier/utils/qr_payload_decoder.dart';

void main() {
  test('decodes MySUF warga QR payload into NIK', () {
    const nik = '3201010101010001';
    final rawBytes = utf8.encode(nik);
    final keyBytes = utf8.encode(AppConstants.qrisSecretKey);
    final xorBytes = List<int>.generate(
      rawBytes.length,
      (index) => rawBytes[index] ^ keyBytes[index % keyBytes.length],
    );
    final qrData = 'MYSUF-QRIS:KTP:${base64.encode(xorBytes)}';

    expect(QrPayloadDecoder.decodeOrRaw(qrData), nik);
  });

  test('returns raw value when payload is not MySUF QR format', () {
    expect(
      QrPayloadDecoder.decodeOrRaw('  3201010101010001  '),
      '3201010101010001',
    );
  });
}