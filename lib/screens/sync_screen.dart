import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/pending_transaction_card.dart';
import '../widgets/section_header.dart';
import '../widgets/sync_action_card.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20;

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
          _WarningBanner(),
          const SizedBox(height: 16),
          const SyncActionCard(count: '5'),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Daftar Transaksi Pending'),
          const SizedBox(height: 12),
          ...pendingTransactions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PendingTransactionCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE1A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.statusWarning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Offline Aktif',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Transaksi akan disimpan secara lokal dan akan disinkronkan saat koneksi kembali.',
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
}
