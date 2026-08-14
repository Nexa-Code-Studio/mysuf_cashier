import 'package:flutter_test/flutter_test.dart';
import 'package:subsidia_cashier/app_session.dart';
import 'package:subsidia_cashier/auth/auth_repository.dart';
import 'package:subsidia_cashier/auth/auth_session.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.session});

  final AuthSession? session;
  bool signOutCalled = false;
  bool clearSessionCalled = false;

  @override
  Future<AuthSession> signIn(String email, String password) async {
    return session!;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<void> clearSession() async {
    clearSessionCalled = true;
  }

  @override
  Future<String?> loadAccessToken() async => null;

  @override
  Future<String?> loadRefreshToken() async => null;

  @override
  Future<String> refreshAccessToken(String refreshToken) async => '';
}

void main() {
  test(
    'signOut revokes backend session then clears local auth state',
    () async {
      const session = AuthSession(
        accessToken: 'access',
        refreshToken: 'refresh',
        tokenType: 'bearer',
        userId: '1',
        userName: 'Cashier',
        userEmail: 'cashier@example.com',
        roles: ['SALES_OFFICER'],
        allowedApps: ['POS_ANDROID'],
        gasStationId: 'station-1',
      );
      final repository = _FakeAuthRepository(session: session);
      final appSession = AppSession(authRepository: repository);

      await appSession.signIn(
        email: 'cashier@example.com',
        password: 'secret123',
      );
      expect(appSession.isAuthenticated, isTrue);

      await appSession.signOut();

      expect(repository.signOutCalled, isTrue);
      expect(repository.clearSessionCalled, isTrue);
      expect(appSession.isAuthenticated, isFalse);
      expect(appSession.authSession, isNull);
    },
  );
}
