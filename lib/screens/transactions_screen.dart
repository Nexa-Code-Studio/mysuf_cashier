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
  String _activeFilter = 'Semua';
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

    if (_activeFilter != 'Semua') {
      items = items.where((item) => item.status == _activeFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.id.toLowerCase().contains(_searchQuery) ||
            item.userName.toLowerCase().contains(_searchQuery) ||
            item.userNik.toLowerCase().contains(_searchQuery) ||
            item.plate.toLowerCase().contains(_searchQuery);
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
              hintText: 'Cari transaksi, NIK, atau plat nomor...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterChip(
                label: 'Semua (${transactions.length})',
                isActive: _activeFilter == 'Semua',
                onTap: () => setState(() => _activeFilter = 'Semua'),
              ),
              _FilterChip(
                label:
                    'Berhasil (${transactions.where((t) => t.status == 'Berhasil').length})',
                isActive: _activeFilter == 'Berhasil',
                onTap: () => setState(() => _activeFilter = 'Berhasil'),
              ),
              _FilterChip(
                label:
                    'Pending (${transactions.where((t) => t.status == 'Pending').length})',
                isActive: _activeFilter == 'Pending',
                onTap: () => setState(() => _activeFilter = 'Pending'),
              ),
              _FilterChip(
                label:
                    'Gagal (${transactions.where((t) => t.status == 'Gagal').length})',
                isActive: _activeFilter == 'Gagal',
                onTap: () => setState(() => _activeFilter = 'Gagal'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionHeader(
            title: '${currentTransactions.length} transaksi ditemukan',
            trailing: TextButton(
              onPressed: () {
                // TODO: Implement export functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur export akan segera hadir!'),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Export'),
            ),
          ),
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
