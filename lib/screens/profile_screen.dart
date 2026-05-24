import 'package:flutter/material.dart';
import '../app_session.dart';
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
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
    const double horizontalPadding = 20;

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
          const ProfileCard(info: profileInfo),
          const SizedBox(height: 20),
          Text(
            'Statistik Hari Ini',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              for (final item in dailyStats)
                StatTile(
                  label: item.label,
                  value: item.value,
                  highlight: item.highlight,
                ),
            ],
          ),
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
}
