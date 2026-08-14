import 'dart:convert';

import '../core/constants/app_constants.dart';

class QrPayloadDecoder {
  static const String _qrPrefix = 'SUBSIDIA-QRIS:KTP:';

  static String decodeOrRaw(String rawValue) {
    final String trimmedValue = rawValue.trim();
    if (!trimmedValue.startsWith(_qrPrefix)) {
      return trimmedValue;
    }

    final String encodedNik = trimmedValue.substring(_qrPrefix.length);
    if (encodedNik.isEmpty) {
      throw const FormatException('Payload QR warga kosong.');
    }

    final List<int> xorBytes = base64.decode(encodedNik);
    final List<int> keyBytes = utf8.encode(AppConstants.qrisSecretKey);
    final List<int> nikBytes = List<int>.generate(
      xorBytes.length,
      (int index) => xorBytes[index] ^ keyBytes[index % keyBytes.length],
    );

    return utf8.decode(nikBytes);
  }
}