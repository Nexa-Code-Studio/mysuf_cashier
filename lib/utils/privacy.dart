String maskNik(String nik) {
  final String digitsOnly = nik.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.length <= 4) {
    return nik;
  }

  final String visibleTail = digitsOnly.substring(digitsOnly.length - 4);
  final String maskedHead = List<String>.filled(digitsOnly.length - 4, '•').join();
  return '$maskedHead$visibleTail';
}
