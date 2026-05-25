import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import 'auth_secure_storage.dart';
import 'auth_session.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient, AuthSecureStorage? secureStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _secureStorage = secureStorage ?? AuthSecureStorage();

  final ApiClient _apiClient;
  final AuthSecureStorage _secureStorage;

  Future<AuthSession> signIn(String email, String password) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'client_type': AppConstants.cashierClientType,
        },
      );

      final payload = response.data;
      if (payload == null) {
        throw Exception('Backend tidak mengembalikan data login.');
      }

      final session = AuthSession.fromJson(payload);
      _ensureCashierAccess(session);
      await _secureStorage.saveSession(session);
      return session;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AuthSession> refreshSession(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
          'client_type': AppConstants.cashierClientType,
        },
      );

      final payload = response.data;
      if (payload == null) {
        throw Exception('Backend tidak mengembalikan data refresh token.');
      }

      final session = AuthSession.fromJson(payload);
      _ensureCashierAccess(session);
      await _secureStorage.saveSession(session);
      return session;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AuthSession?> loadStoredSession() {
    return _secureStorage.loadSession();
  }

  Future<String?> loadRefreshToken() {
    return _secureStorage.loadRefreshToken();
  }

  Future<String?> loadAccessToken() {
    return _secureStorage.loadAccessToken();
  }

  Future<void> persistSession(AuthSession session) {
    return _secureStorage.saveSession(session);
  }

  Future<void> clearSession() {
    return _secureStorage.clearSession();
  }

  Future<void> signOut() async {
    try {
      await _apiClient.dio.post<void>('/auth/logout');
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return;
      }
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final session = await refreshSession(refreshToken);
    return session.accessToken;
  }

  void _ensureCashierAccess(AuthSession session) {
    if (!session.allowedApps.contains(AppConstants.cashierClientType)) {
      throw Exception('Akun ini tidak memiliki akses ke aplikasi kasir.');
    }
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }

    return error.message ?? 'Terjadi kesalahan jaringan. Coba lagi.';
  }
}
