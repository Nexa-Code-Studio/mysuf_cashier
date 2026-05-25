import 'package:flutter/material.dart';

import 'auth/auth_repository.dart';
import 'auth/auth_session.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';

class AppSession extends ChangeNotifier {
  AppSession({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _configureApiAuth();
  }

  final AuthRepository _authRepository;

  AuthSession? _authSession;
  bool _isAuthenticated = false;
  bool _isBusy = false;
  bool _isInitializing = true;
  int _cashierDataRevision = 0;

  bool get isAuthenticated => _isAuthenticated;

  bool get isBusy => _isBusy;

  bool get isInitializing => _isInitializing;

  AuthSession? get authSession => _authSession;

  String get email => _authSession?.userEmail ?? '';

  String get userName => _authSession?.userName ?? '';

  String? get gasStationId => _authSession?.gasStationId;

  int get cashierDataRevision => _cashierDataRevision;

  void _configureApiAuth() {
    ApiClient.configureAuth(
      loadAccessToken: _authRepository.loadAccessToken,
      loadRefreshToken: _authRepository.loadRefreshToken,
      refreshAccessToken: _authRepository.refreshAccessToken,
      clearSession: _authRepository.clearSession,
    );
  }

  Future<void> bootstrap() async {
    if (!_isInitializing) {
      return;
    }

    try {
      final refreshToken = await _authRepository.loadRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _authRepository.clearSession();
        _authSession = null;
        _isAuthenticated = false;
        return;
      }

      final session = await _authRepository.refreshSession(refreshToken);
      _authSession = session;
      _isAuthenticated = true;
    } catch (_) {
      await _authRepository.clearSession();
      _authSession = null;
      _isAuthenticated = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _isBusy = true;
    notifyListeners();

    try {
      final session = await _authRepository.signIn(email, password);
      if (!session.allowedApps.contains(AppConstants.cashierClientType)) {
        throw Exception('Akun ini tidak memiliki akses ke aplikasi kasir.');
      }

      _authSession = session;
      _isAuthenticated = true;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isBusy = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      await _authRepository.clearSession();
      _authSession = null;
      _isAuthenticated = false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void bumpCashierDataRevision() {
    _cashierDataRevision += 1;
    notifyListeners();
  }
}

class SessionScope extends InheritedNotifier<AppSession> {
  const SessionScope({
    super.key,
    required AppSession session,
    required super.child,
  }) : super(notifier: session);

  static AppSession of(BuildContext context) {
    final SessionScope? scope = context
        .dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope not found in widget tree');
    return scope!.notifier!;
  }
}
