import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
            'Riwayat Transaksi',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '15 Mei 2026',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: verticalSpacing),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Pendapatan',
                  value: 'Rp 1.126.800',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Total Liter',
                  value: '162 L',
                  backgroundColor: AppColors.surface,
                  textColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: verticalSpacing),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari transaksi, NIK, atau plat nomor...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FilterChip(label: 'Semua (6)', isActive: true),
              _FilterChip(label: 'Berhasil (4)'),
              _FilterChip(label: 'Pending (1)'),
              _FilterChip(label: 'Gagal (1)'),
            ],
          ),
          const SizedBox(height: 12),
          SectionHeader(
            title: '6 transaksi ditemukan',
            trailing: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Export'),
            ),
          ),
          const SizedBox(height: 12),
          ...transactions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final Color background = isActive ? AppColors.primary : AppColors.surface;
    final Color textColor = isActive ? Colors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primary : const Color(0xFFE3E3E3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
