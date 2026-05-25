import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

class ApiClient {
  static Future<String?> Function()? _accessTokenLoader;
  static Future<String?> Function()? _refreshTokenLoader;
  static Future<String> Function(String refreshToken)? _refreshAccessToken;
  static Future<void> Function()? _clearSession;

  ApiClient({Dio? dio})
    : dio = dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _accessTokenLoader?.call();
          final hasAuthorizationHeader =
              options.headers.containsKey('Authorization');
          if (!hasAuthorizationHeader && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final requestOptions = error.requestOptions;
          final canRetry = requestOptions.extra['retried'] != true;
          final isAuthEndpoint = requestOptions.path.contains('/auth/login') ||
              requestOptions.path.contains('/auth/refresh');

          if (response?.statusCode != 401 || !canRetry || isAuthEndpoint) {
            handler.next(error);
            return;
          }

          final refreshToken = await _refreshTokenLoader?.call();
          if (refreshToken == null || refreshToken.isEmpty) {
            await _clearSession?.call();
            handler.next(error);
            return;
          }

          try {
            final newAccessToken = await _refreshAccessToken?.call(refreshToken);
            if (newAccessToken == null || newAccessToken.isEmpty) {
              await _clearSession?.call();
              handler.next(error);
              return;
            }

            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            requestOptions.extra['retried'] = true;
            final retryResponse = await this.dio.fetch<dynamic>(requestOptions);
            handler.resolve(retryResponse);
          } catch (_) {
            await _clearSession?.call();
            handler.next(error);
          }
        },
      ),
    );
  }

  final Dio dio;

  static void configureAuth({
    required Future<String?> Function() loadAccessToken,
    required Future<String?> Function() loadRefreshToken,
    required Future<String> Function(String refreshToken) refreshAccessToken,
    required Future<void> Function() clearSession,
  }) {
    _accessTokenLoader = loadAccessToken;
    _refreshTokenLoader = loadRefreshToken;
    _refreshAccessToken = refreshAccessToken;
    _clearSession = clearSession;
  }
}
