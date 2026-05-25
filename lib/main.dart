import 'package:flutter/material.dart';
import 'app_session.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';
import 'screens/splash_screen.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppSession _session;

  @override
  void initState() {
    super.initState();
    _session = AppSession();
    _session.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: _session,
      child: AnimatedBuilder(
        animation: _session,
        builder: (context, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'MySUF Cashier',
                  theme: AppTheme.lightTheme(),
                  home: _session.isInitializing
                      ? const SplashScreen()
                      : _session.isAuthenticated
                      ? const MainLayout()
                      : const LoginScreen(),
                ),
                if (_session.isBusy)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: false,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _session.isAuthenticated
                                    ? 'Memproses logout...'
                                    : 'Memproses login...',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
