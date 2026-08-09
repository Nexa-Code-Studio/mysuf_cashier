class AppConstants {
  static const String appName = 'MySUF Cashier';
  static const bool useLocalhost = bool.fromEnvironment(
    'USE_LOCALHOST',
    defaultValue: false,
  );

  static const String apiBaseUrl = useLocalhost
      ? 'http://localhost:8080/api/v1'
      : String.fromEnvironment(
          'MYSUF_API_BASE_URL',
          defaultValue: 'https://api.smkn1wringin.sch.id/api/v1',
        );
  static const String cashierClientType = 'POS_ANDROID';
  static const String qrisSecretKey = 'YTAU!@*@!^18728yLAHD{:{{';
}
