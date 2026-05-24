import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _activeTimeFilter = 'Semua Waktu';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionItem> get _filteredTransactions {
    List<TransactionItem> items = List.from(transactions);

    if (_activeTimeFilter != 'Semua Waktu') {
      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);

      items = items.where((item) {
        if (_activeTimeFilter == 'Hari Ini') {
          return item.occurredAt.year == now.year &&
              item.occurredAt.month == now.month &&
              item.occurredAt.day == now.day;
        }

        if (_activeTimeFilter == '7 Hari Terakhir') {
          final DateTime start = todayStart.subtract(const Duration(days: 6));
          return !item.occurredAt.isBefore(start) &&
              item.occurredAt.isBefore(todayStart.add(const Duration(days: 1)));
        }

        if (_activeTimeFilter == '1 Bulan Terakhir') {
          final DateTime start = DateTime(now.year, now.month - 1, now.day);
          return !item.occurredAt.isBefore(start);
        }

        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.id.toLowerCase().contains(_searchQuery) ||
            item.userName.toLowerCase().contains(_searchQuery) ||
            item.userNik.toLowerCase().contains(_searchQuery) ||
            item.plate.toLowerCase().contains(_searchQuery) ||
            item.fuel.toLowerCase().contains(_searchQuery) ||
            item.payment.toLowerCase().contains(_searchQuery) ||
            item.cashier.toLowerCase().contains(_searchQuery) ||
            item.status.toLowerCase().contains(_searchQuery) ||
            item.date.toLowerCase().contains(_searchQuery) ||
            item.total.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20;
    const double verticalSpacing = 16;
    final List<TransactionItem> currentTransactions = _filteredTransactions;

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
            style: Theme.of(context).textTheme.headlineSmall,
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari transaksi, NIK, plat, atau metode bayar...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterChip(
                label: 'Semua Waktu',
                isActive: _activeTimeFilter == 'Semua Waktu',
                onTap: () => setState(() => _activeTimeFilter = 'Semua Waktu'),
              ),
              _FilterChip(
                label: 'Hari Ini',
                isActive: _activeTimeFilter == 'Hari Ini',
                onTap: () => setState(() => _activeTimeFilter = 'Hari Ini'),
              ),
              _FilterChip(
                label: '7 Hari Terakhir',
                isActive: _activeTimeFilter == '7 Hari Terakhir',
                onTap: () => setState(() => _activeTimeFilter = '7 Hari Terakhir'),
              ),
              _FilterChip(
                label: '1 Bulan Terakhir',
                isActive: _activeTimeFilter == '1 Bulan Terakhir',
                onTap: () => setState(() => _activeTimeFilter = '1 Bulan Terakhir'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionHeader(title: '${currentTransactions.length} transaksi ditemukan'),
          const SizedBox(height: 12),
          if (currentTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada transaksi ditemukan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...currentTransactions.map(
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
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color background = isActive ? AppColors.primary : AppColors.surface;
    final Color textColor = isActive ? Colors.white : AppColors.textPrimary;
    final Color borderColor = isActive ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
