class AppConstants {
  static const String appName = 'MySUF Cashier';
  static const String apiBaseUrl = String.fromEnvironment(
    'MYSUF_API_BASE_URL',
    defaultValue: 'https://api.smkn1wringin.sch.id/api/v1',
  );
  static const String cashierClientType = 'POS_ANDROID';
  static const String qrisSecretKey = 'YTAU!@*@!^18728yLAHD{:{{';
}
