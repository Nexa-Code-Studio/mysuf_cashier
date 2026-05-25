import 'package:flutter/material.dart';

import '../app_session.dart';
import '../cashier/cashier_buyer_repository.dart';
import '../models/cashier_history_models.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/profile_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';
import 'performance_stat_screen.dart';
import 'shift_schedule_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  AppSession? _session;
  int _seenRevision = 0;
  CashierPerformanceSummary? _summary;
  bool _isLoadingStats = false;
  String? _statsErrorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = SessionScope.of(context);
    if (_session == session) {
      return;
    }

    _session?.removeListener(_handleSessionChanged);
    _session = session;
    _seenRevision = session.cashierDataRevision;
    _session?.addListener(_handleSessionChanged);
    _loadStats();
  }

  @override
  void dispose() {
    _session?.removeListener(_handleSessionChanged);
    super.dispose();
  }

  void _handleSessionChanged() {
    final session = _session;
    if (session == null || session.cashierDataRevision == _seenRevision) {
      return;
    }

    _seenRevision = session.cashierDataRevision;
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingStats = true;
      _statsErrorMessage = null;
    });

    try {
      final snapshot = await _repository.getCashierPerformance(recentLimit: 5);
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = snapshot.summary;
        _isLoadingStats = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingStats = false;
        _statsErrorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Keluar dari aplikasi?'),
          content: const Text(
            'Anda akan kembali ke halaman login dan perlu masuk lagi untuk melanjutkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await SessionScope.of(context).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppSession session = SessionScope.of(context);
    const double horizontalPadding = 20;
    final summary = _summary;
    final profile = ProfileInfo(
      name: session.userName.isEmpty ? profileInfo.name : session.userName,
      role:
          session.authSession?.roles.join(', ').replaceAll('_', ' ') ??
          profileInfo.role,
      id: session.gasStationId ?? profileInfo.id,
      station: session.gasStationId == null || session.gasStationId!.isEmpty
          ? profileInfo.station
          : 'SPBU ID ${session.gasStationId}',
      joined: profileInfo.joined,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Kasir',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ProfileCard(info: profile),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Login',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  session.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Statistik Hari Ini',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_isLoadingStats && summary == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_statsErrorMessage != null && summary == null)
            _buildStatsError(context)
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatTile(
                  label: 'Transaksi',
                  value: summary?.totalTransactions.toString() ?? '0',
                ),
                StatTile(
                  label: 'Pendapatan',
                  value: summary?.totalRevenueCompactLabel ?? 'Rp 0',
                  highlight: true,
                ),
                StatTile(
                  label: 'Total Liter',
                  value: summary?.totalLitersCompactLabel ?? '0 L',
                ),
                StatTile(
                  label: 'Rata-rata Waktu',
                  value: summary?.averageTransactionLabel ?? '-',
                ),
              ],
            ),
          if (_statsErrorMessage != null && summary != null) ...[
            const SizedBox(height: 12),
            Text(
              _statsErrorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader(title: 'Statistik'),
          const SizedBox(height: 8),
          _buildTile(
            'Performa Hari Ini',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerformanceStatScreen(),
                ),
              );
            },
          ),
          _buildTile(
            'Waktu Shift',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftScheduleScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Pengaturan'),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notifikasi'),
            value: _notificationsEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Sync'),
            value: _autoSyncEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => setState(() => _autoSyncEnabled = value),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Keamanan & Bantuan'),
          const SizedBox(height: 8),
          _buildTile('Keamanan & Privasi'),
          _buildTile('Bantuan & Dukungan'),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _confirmLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Text(
                'Keluar / Logout',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  'SPBU POS System v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Copyright 2026',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildStatsError(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statsErrorMessage ?? 'Gagal memuat statistik.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _loadStats, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
