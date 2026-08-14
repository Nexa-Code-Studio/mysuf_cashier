import 'package:flutter/material.dart';

import '../app_session.dart';
import '../cashier/cashier_buyer_repository.dart';
import '../models/cashier_history_models.dart';
import '../theme/theme.dart';

class PerformanceStatScreen extends StatefulWidget {
  const PerformanceStatScreen({super.key});

  @override
  State<PerformanceStatScreen> createState() => _PerformanceStatScreenState();
}

class _PerformanceStatScreenState extends State<PerformanceStatScreen> {
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  AppSession? _session;
  int _seenRevision = 0;
  CashierPerformanceSnapshot? _snapshot;
  bool _isLoading = true;
  String? _errorMessage;

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
    _loadPerformance();
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
    _loadPerformance();
  }

  Future<void> _loadPerformance() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await _repository.getCashierPerformance(recentLimit: 5);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final summary = snapshot?.summary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Statistik Performa',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading && snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && snapshot == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loadPerformance,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE31837), Color(0xFFB3122B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pendapatan Hari Ini',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          summary?.totalRevenueLabel ?? 'Rp 0',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _StatBox(
                        title: 'Transaksi Sukses',
                        value: '${summary?.completedTransactions ?? 0} Transaksi',
                      ),
                      _StatBox(
                        title: 'Total Volume BBM',
                        value: summary?.totalLitersLabel ?? '0 Liter',
                      ),
                      _StatBox(
                        title: 'Rata-rata Waktu Transaksi',
                        value: summary?.averageTransactionLabel ?? '-',
                        badgeText: summary?.averageTransactionMinutes == null
                            ? null
                            : 'Backend',
                      ),
                      _StatBox(
                        title: 'Transaksi Gagal/Ditolak',
                        value:
                            '${summary?.failedOrRejectedTransactions ?? 0} Transaksi',
                      ),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Transaksi Terakhir',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if ((snapshot?.recentTransactions.length ?? 0) == 0)
                    Text(
                      'Belum ada transaksi hari ini.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot?.recentTransactions.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = snapshot!.recentTransactions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (item.plate != '-' && item.plate.trim().isNotEmpty)
                                          ? item.plate
                                          : 'Transaksi Personal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${item.fuel} · ${item.liters}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                item.date,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final String? badgeText;

  const _StatBox({required this.title, required this.value, this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusSafe.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.statusSafe,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
