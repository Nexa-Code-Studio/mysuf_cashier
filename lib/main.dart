import 'package:flutter/material.dart';
import 'screens/main_layout.dart';
import 'theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySUF Cashier',
      theme: AppTheme.lightTheme(),
      home: const MainLayout(),
    );
  }
}
