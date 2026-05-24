import 'package:flutter/material.dart';
import '../app_session.dart';
import '../theme/theme.dart';
import '../widgets/pos_app_bar.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'sync_screen.dart';
import 'transactions_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScanScreen(),
    TransactionsScreen(),
    SyncScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final AppSession session = SessionScope.of(context);

    return Scaffold(
      appBar: PosAppBar(
        operatorEmail: session.email,
        onLogout: session.signOut,
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_outlined),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
