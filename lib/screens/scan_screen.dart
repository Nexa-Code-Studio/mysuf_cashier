import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/menu_card.dart';
import '../widgets/section_header.dart';
import 'ktp_scanner_screen.dart';
import 'manual_nik_screen.dart';
import 'qr_scanner_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20;
    const double verticalSpacing = 16;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPBU POS System',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih metode identifikasi pengguna',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: verticalSpacing),
          ...scanMethods.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MenuCard(
                icon: entry.value.icon,
                title: entry.value.title,
                subtitle: entry.value.subtitle,
                onTap: () {
                  switch (entry.key) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QrScannerScreen(),
                        ),
                      );
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KtpScannerScreen(),
                        ),
                      );
                      break;
                    default:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManualNikScreen(),
                        ),
                      );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          SectionHeader(title: 'Recent Scans', icon: Icons.access_time_rounded),
          const SizedBox(height: 12),
          ...recentScans.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecentScanCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentScanCard extends StatelessWidget {
  final RecentScanItem item;

  const _RecentScanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  item.nik,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.timeAgo,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
