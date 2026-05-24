import 'package:flutter/material.dart';

class AppSession extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isBusy = false;
  String _email = '';

  bool get isAuthenticated => _isAuthenticated;

  bool get isBusy => _isBusy;

  String get email => _email;

  Future<void> signIn({required String email}) async {
    _isBusy = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    _isAuthenticated = true;
    _email = email;
    _isBusy = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isBusy = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    _isAuthenticated = false;
    _email = '';
    _isBusy = false;
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
    final SessionScope? scope =
        context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope not found in widget tree');
    return scope!.notifier!;
  }
}