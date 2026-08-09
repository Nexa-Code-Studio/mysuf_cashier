import 'package:flutter/material.dart';
import '../app_session.dart';
import '../cashier/cashier_buyer_repository.dart';
import '../models/cashier_history_models.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/menu_card.dart';
import '../widgets/section_header.dart';
import 'ktp_scanner_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<CashierRecentScanItem> _items = const [];
  AppSession? _session;
  int _seenRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
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
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final page = await _repository.getRecentScans(limit: 10);
      if (!mounted) return;
      setState(() {
        _items = page.items;
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

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20;
    const double verticalSpacing = 16;

    return RefreshIndicator(
      onRefresh: _loadRecentScans,
      child: CustomScrollView(
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
                    'SPBU POS System',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Identifikasi Pengguna',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: verticalSpacing),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MenuCard(
                      icon: Icons.contact_emergency_outlined,
                      title: 'Scan E-KTP / Kartu NFC',
                      subtitle: 'Tempelkan E-KTP atau kartu NFC kendaraan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KtpScannerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SectionHeader(
                    title: 'Recent Scans',
                    icon: Icons.access_time_rounded,
                  ),
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
                        onPressed: _loadRecentScans,
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
                child: Text(
                  'Belum ada riwayat scan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList.separated(
                itemCount: _items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _RecentScanCard(item: item);
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _RecentScanCard extends StatelessWidget {
  final CashierRecentScanItem item;

  const _RecentScanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.nikMasked,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.timeLabel, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                '${item.status} · ${item.method}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: item.status == 'Berhasil'
                          ? AppColors.statusSafe
                          : AppColors.statusCritical,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
