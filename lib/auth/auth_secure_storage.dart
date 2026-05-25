import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

class AuthSecureStorage {
  AuthSecureStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _keys = <String>[
    'access_token',
    'refresh_token',
    'token_type',
    'user_id',
    'user_name',
    'user_email',
    'roles',
    'allowed_apps',
    'gas_station_id',
  ];

  final FlutterSecureStorage _secureStorage;

  Future<void> saveSession(AuthSession session) async {
    final data = session.toStorageMap();
    for (final entry in data.entries) {
      await _secureStorage.write(key: entry.key, value: entry.value);
    }
  }

  Future<AuthSession?> loadSession() async {
    final data = <String, String>{};
    for (final key in _keys) {
      final value = await _secureStorage.read(key: key);
      if (value != null) {
        data[key] = value;
      }
    }

    if ((data['access_token'] ?? '').isEmpty ||
        (data['refresh_token'] ?? '').isEmpty) {
      return null;
    }

    return AuthSession.fromStorageMap(data);
  }

  Future<String?> loadRefreshToken() {
    return _secureStorage.read(key: 'refresh_token');
  }

  Future<String?> loadAccessToken() {
    return _secureStorage.read(key: 'access_token');
  }

  Future<void> clearSession() async {
    for (final key in _keys) {
      await _secureStorage.delete(key: key);
    }
  }
}
