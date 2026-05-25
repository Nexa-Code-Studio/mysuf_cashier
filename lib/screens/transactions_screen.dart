import 'dart:async';

import 'package:flutter/material.dart';
import '../app_session.dart';
import '../cashier/cashier_buyer_repository.dart';
import '../models/cashier_history_models.dart';
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
  final ScrollController _scrollController = ScrollController();
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  Timer? _debounce;
  AppSession? _session;
  int _seenRevision = 0;

  List<CashierTransactionItem> _items = const [];
  CashierTransactionSummary? _summary;
  String? _nextCursor;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_handleSearchChanged);
    _loadTransactions();
  }

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
  }

  @override
  void dispose() {
    _session?.removeListener(_handleSessionChanged);
    _debounce?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSessionChanged() {
    final session = _session;
    if (session == null) {
      return;
    }

    if (session.cashierDataRevision == _seenRevision) {
      return;
    }

    _seenRevision = session.cashierDataRevision;
    _loadTransactions();
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text;
    if (nextQuery == _searchQuery) {
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = nextQuery;
      });
      _loadTransactions();
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) {
      return;
    }

    const double threshold = 240;
    if (_scrollController.position.extentAfter < threshold) {
      _loadMoreTransactions();
    }
  }

  ({DateTime? from, DateTime? to}) _resolveDateRange() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (_activeTimeFilter) {
      case 'Hari Ini':
        return (from: todayStart, to: todayStart.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)));
      case '7 Hari Terakhir':
        return (from: todayStart.subtract(const Duration(days: 6)), to: todayStart.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)));
      case '1 Bulan Terakhir':
        return (from: DateTime(now.year, now.month - 1, now.day), to: now);
      default:
        return (from: null, to: null);
    }
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _items = const [];
      _summary = null;
      _nextCursor = null;
      _hasMore = false;
    });

    try {
      final range = _resolveDateRange();
      final page = await _repository.getCashierTransactions(
        query: _searchQuery,
        dateFrom: range.from,
        dateTo: range.to,
        limit: 20,
        includeSummary: true,
      );

      if (!mounted) return;
      setState(() {
        _items = page.items;
        _summary = page.summary;
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      return;
    }

    setState(() => _isLoadingMore = true);
    try {
      final range = _resolveDateRange();
      final page = await _repository.getCashierTransactions(
        query: _searchQuery,
        dateFrom: range.from,
        dateTo: range.to,
        cursor: _nextCursor,
        limit: 20,
        includeSummary: false,
      );

      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20;
    const double verticalSpacing = 16;
    final summary = _summary;
    final String totalTransactionsLabel = summary?.totalTransactions.toString() ?? '0';

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Transaksi',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Data terbaru dari backend',
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
                          value: summary?.totalRevenueLabel ?? 'Rp 0',
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Liter',
                          value: summary?.totalLitersLabel ?? '0 L',
                          backgroundColor: AppColors.surface,
                          textColor: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: verticalSpacing),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari transaksi, NIK, plat, atau metode bayar...',
                      prefixIcon: Icon(Icons.search),
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
                        onTap: () => setState(() {
                          _activeTimeFilter = 'Semua Waktu';
                          _loadTransactions();
                        }),
                      ),
                      _FilterChip(
                        label: 'Hari Ini',
                        isActive: _activeTimeFilter == 'Hari Ini',
                        onTap: () => setState(() {
                          _activeTimeFilter = 'Hari Ini';
                          _loadTransactions();
                        }),
                      ),
                      _FilterChip(
                        label: '7 Hari Terakhir',
                        isActive: _activeTimeFilter == '7 Hari Terakhir',
                        onTap: () => setState(() {
                          _activeTimeFilter = '7 Hari Terakhir';
                          _loadTransactions();
                        }),
                      ),
                      _FilterChip(
                        label: '1 Bulan Terakhir',
                        isActive: _activeTimeFilter == '1 Bulan Terakhir',
                        onTap: () => setState(() {
                          _activeTimeFilter = '1 Bulan Terakhir';
                          _loadTransactions();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SectionHeader(title: '$totalTransactionsLabel transaksi ditemukan'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                            color: AppColors.textSecondary.withAlpha(128),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadTransactions,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.textSecondary.withAlpha(128),
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
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList.separated(
                itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= _items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final item = _items[index];
                  return TransactionCard(item: item);
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
