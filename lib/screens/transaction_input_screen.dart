import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../cashier/cashier_buyer_repository.dart';
import '../models/cashier_buyer_lookup.dart';
import '../models/mock_data.dart';
import '../models/transaction_draft.dart';
import '../theme/theme.dart';
import 'payment_screen.dart';

class TransactionInputScreen extends StatefulWidget {
  final CashierVehicleInfo vehicle;
  final String? buyerName;
  final String? buyerNik;
  final bool isPinActive;
  final CashierBuyerInfo? buyer;

  const TransactionInputScreen({
    super.key,
    required this.vehicle,
    this.buyerName,
    this.buyerNik,
    this.isPinActive = false,
    this.buyer,
  });

  @override
  State<TransactionInputScreen> createState() => _TransactionInputScreenState();
}

class _TransactionInputScreenState extends State<TransactionInputScreen> {
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  List<Map<String, dynamic>> _fuelTypes = [];
  Map<String, dynamic>? _selectedFuelType;
  bool _isLoadingFuels = true;
  String? _errorMessage;

  bool _isInputLiters = false;
  double _liters = 0.0;
  int _totalPrice = 0;

  Timer? _debounceTimer;
  bool _isCalculatingPricing = false;
  FuelPricingBreakdown? _backendPricing;

  @override
  void initState() {
    super.initState();
    _plateController.text = widget.vehicle.plateNumber;
    _plateController.addListener(_onPlateChanged);
    _inputController.addListener(_handleInputChange);
    _loadFuels();

    // [DEBUG LOG] Trace buyer state received from API
    final b = widget.buyer;
    if (b != null) {
      debugPrint('[CASHIER DEBUG] Buyer: ${b.name} (${b.nikSnapshot})');
      debugPrint('[CASHIER DEBUG] accountStatus=${b.accountStatus}');
      debugPrint('[CASHIER DEBUG] isBlocked=${b.isBlocked} | isFrozen=${b.isFrozen} | isEligible=${b.isEligible}');
      debugPrint('[CASHIER DEBUG] frozenUntil=${b.frozenUntil}');
      debugPrint('[CASHIER DEBUG] quotaLiters=${b.quotaLiters} | usedLiters=${b.usedLiters} | remainingLiters=${b.remainingLiters}');
    } else {
      debugPrint('[CASHIER DEBUG] widget.buyer is NULL — status will fall back to vehicle eligibility only');
    }
  }

  void _onPlateChanged() {
    _calculatePricingLocal();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _plateController.removeListener(_onPlateChanged);
    _plateController.dispose();
    _inputController.removeListener(_handleInputChange);
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadFuels() async {
    try {
      final fuels = await _repository.getFuels();
      setState(() {
        _fuelTypes = fuels;
        if (fuels.isNotEmpty) {
          _selectedFuelType = fuels.first;
        }
        _isLoadingFuels = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoadingFuels = false;
      });
    }
  }

  double get _remainingQuota => widget.vehicle.remainingLiters;

  String get _accountStatus =>
      _backendPricing?.accountStatus ??
      widget.buyer?.accountStatus ??
      'ACTIVE';


  bool get _selectedFuelTypeIsSubsidized =>
      _selectedFuelType?['subsidy_type'] == 'SUBSIDIZED';

  FuelPricingBreakdown? get _pricingBreakdown => _backendPricing;

  String _buildFuelChipLabel(Map<String, dynamic> fuel) {
    final name = fuel['name']?.toString() ?? '-';
    final marketPrice = _formatCurrency(
      ((fuel['price_per_liter'] as num?) ?? 0).round(),
    );
    final subsidyPrice = fuel['subsidy_price_per_liter'] as num?;
    final isSubsidized = fuel['subsidy_type'] == 'SUBSIDIZED';

    if (!isSubsidized || subsidyPrice == null) {
      return '$name\n($marketPrice/L)';
    }

    return '$name\n(${_formatCurrency(subsidyPrice.round())}/L subsidi | $marketPrice/L normal)';
  }

  String get _statusTitle {
    switch (_accountStatus) {
      case 'BANNED':          return 'Status: Akun KTP Diblokir';
      case 'FROZEN':          return 'Status: Akun KTP Dibekukan';
      case 'NOT_ELIGIBLE':    return 'Status: Tidak Layak Subsidi';
      case 'QUOTA_EXHAUSTED': return 'Status: Kuota Subsidi Habis';
      default:                return 'Status: Kuota Subsidi Tersedia';
    }
  }

  String get _statusDetail {
    switch (_accountStatus) {
      case 'BANNED':
        return 'Akun KTP ini diblokir permanen karena terdeteksi fraud. Transaksi BBM hanya dapat menggunakan harga normal.';
      case 'FROZEN':
        String until = widget.buyer?.frozenUntil ?? 'Waktu tidak ditentukan';
        if (until.contains('T')) {
          try {
            final parts = until.split('T');
            final dateParts = parts[0].split('-');
            final timeParts = parts[1].split('.');
            until = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]} ${timeParts[0]}';
          } catch (_) {}
        }
        return 'Akun KTP ini dibekukan sementara karena aktivitas fraud. Dibekukan hingga: $until. Transaksi BBM hanya dapat menggunakan harga normal.';
      case 'NOT_ELIGIBLE':
        return 'KK warga tidak memenuhi syarat subsidi BBM karena penghasilan melebihi batas yang ditentukan. Transaksi menggunakan harga normal.';
      case 'QUOTA_EXHAUSTED':
        return 'Kuota subsidi bulanan warga telah habis. Seluruh liter akan dihitung dengan harga normal.';
      default:
        return 'Sisa kuota ${_remainingQuota.toStringAsFixed(2).replaceAll(".", ",")} Liter. Kuota subsidi akan dipakai lebih dulu.';
    }
  }

  Color get _statusColor {
    switch (_accountStatus) {
      case 'BANNED':          return AppColors.statusCritical;
      case 'FROZEN':          return AppColors.statusCritical;
      case 'NOT_ELIGIBLE':    return const Color(0xFF757575); // abu-abu
      case 'QUOTA_EXHAUSTED': return const Color(0xFFB56A00); // orange
      default:                return AppColors.statusSafe;    // hijau
    }
  }

  Color get _statusBackground {
    switch (_accountStatus) {
      case 'BANNED':          return const Color(0xFFFCE8E8); // merah pucat
      case 'FROZEN':          return const Color(0xFFFCE8E8); // merah pucat
      case 'NOT_ELIGIBLE':    return const Color(0xFFF0F0F0); // abu-abu terang
      case 'QUOTA_EXHAUSTED': return const Color(0xFFFFF3E0); // orange pucat
      default:                return const Color(0xFFE7F7EC); // hijau pucat
    }
  }

  String _getPricingWarningText() {
    switch (_accountStatus) {
      case 'BANNED':          return 'Akun KTP diblokir permanen, jadi seluruh transaksi memakai harga normal.';
      case 'FROZEN':          return 'Akun KTP dibekukan sementara, jadi seluruh transaksi memakai harga normal.';
      case 'NOT_ELIGIBLE':    return 'KK tidak layak subsidi (penghasilan melebihi batas), jadi seluruh transaksi memakai harga normal.';
      case 'QUOTA_EXHAUSTED': return 'Kuota subsidi sudah habis, jadi seluruh transaksi memakai harga normal.';
      default:                return '';
    }
  }

  void _handleInputChange() {
    final String text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _liters = 0.0;
        _totalPrice = 0;
        _backendPricing = null;
      });
      return;
    }
    _calculatePricingLocal();
  }

  void _calculatePricingLocal() {
    final String text = _inputController.text.trim();
    final fuel = _selectedFuelType;
    if (fuel == null || text.isEmpty) {
      setState(() {
        _liters = 0.0;
        _totalPrice = 0;
        _backendPricing = null;
      });
      return;
    }

    double nominal = 0.0;
    if (_isInputLiters) {
      final String sanitizedText = text.replaceAll(',', '.');
      nominal = double.tryParse(sanitizedText) ?? 0.0;
    } else {
      nominal = (int.tryParse(text) ?? 0).toDouble();
    }

    if (nominal <= 0) {
      setState(() {
        _liters = 0.0;
        _totalPrice = 0;
        _backendPricing = null;
      });
      return;
    }

    final double marketPrice = ((fuel['price_per_liter'] as num?) ?? 0).toDouble();
    final double? subsidyPrice = (fuel['subsidy_price_per_liter'] as num?)?.toDouble();
    final bool isSubsidizedFuel = fuel['subsidy_type'] == 'SUBSIDIZED';
    final String status = widget.buyer?.accountStatus ?? 'ACTIVE';
    final bool isEligibleForSubsidy = status == 'ACTIVE';
    final double remainingQuota = (widget.buyer != null && widget.buyer!.remainingLiters > 0)
        ? widget.buyer!.remainingLiters
        : widget.vehicle.remainingLiters;

    FuelPricingBreakdown pricing;
    if (_isInputLiters) {
      pricing = FuelPricingBreakdown.fromLiters(
        liters: nominal,
        marketPricePerLiter: marketPrice,
        subsidizedPricePerLiter: subsidyPrice,
        isSubsidizedFuel: isSubsidizedFuel,
        isEligibleForSubsidy: isEligibleForSubsidy,
        remainingQuota: remainingQuota,
      );
    } else {
      pricing = FuelPricingBreakdown.fromAmount(
        amount: nominal.round(),
        marketPricePerLiter: marketPrice,
        subsidizedPricePerLiter: subsidyPrice,
        isSubsidizedFuel: isSubsidizedFuel,
        isEligibleForSubsidy: isEligibleForSubsidy,
        remainingQuota: remainingQuota,
      );
    }

    setState(() {
      _backendPricing = pricing;
      _liters = pricing.liters;
      _totalPrice = pricing.totalAmount;
      _isCalculatingPricing = false;
      _errorMessage = null;
    });
  }

  void _selectFuelType(Map<String, dynamic> fuelType) {
    setState(() {
      _selectedFuelType = fuelType;
    });
    _handleInputChange();
  }

  bool get _canProceed =>
      !_isCalculatingPricing &&
      _liters > 0 &&
      _selectedFuelType != null &&
      (widget.vehicle.category != 'commercial' ||
          _plateController.text.trim().isNotEmpty);

  String _formatCurrency(int value) {
    final String raw = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final int position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final buyerName = widget.buyerName ?? currentUser.name;
    final buyerNik = widget.buyerNik ?? currentUser.nik;
    final pricing = _pricingBreakdown;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Input Transaksi',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengguna',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    buyerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    buyerNik,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (!widget.vehicle.isPersonal) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Plat Nomor Kendaraan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'N 1234 AB',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_gas_station_rounded, color: _statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusTitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusDetail,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Jenis BBM',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_isLoadingFuels)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(
                'Gagal memuat jenis BBM: $_errorMessage',
                style: const TextStyle(color: AppColors.statusCritical),
              )
            else ...[
              Builder(
                builder: (context) {
                  final chunks = _chunkList(_fuelTypes, 2);
                  return Column(
                    children: chunks.map((rowFuels) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            for (int i = 0; i < rowFuels.length; i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              _FuelChip(
                                label: _buildFuelChipLabel(rowFuels[i]),
                                isSelected:
                                    _selectedFuelType?['id'] ==
                                    rowFuels[i]['id'],
                                onTap: () => _selectFuelType(rowFuels[i]),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_isInputLiters) return;
                      if (_selectedFuelType == null) return;
                      final double currentLiters = _liters;
                      setState(() {
                        _isInputLiters = true;
                        if (currentLiters > 0) {
                          final String formatted = currentLiters.toStringAsFixed(2);
                          _inputController.text = formatted.replaceAll('.', ',');
                        } else {
                          _inputController.clear();
                          _liters = 0.0;
                          _totalPrice = 0;
                          _backendPricing = null;
                        }
                      });
                      _calculatePricingLocal();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isInputLiters
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      side: BorderSide(
                        color: _isInputLiters
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Berdasarkan Liter',
                      style: TextStyle(
                        color: _isInputLiters
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (!_isInputLiters) return;
                      if (_selectedFuelType == null) return;
                      final int currentPrice = _totalPrice;
                      setState(() {
                        _isInputLiters = false;
                        if (currentPrice > 0) {
                          _inputController.text = currentPrice.toString();
                        } else {
                          _inputController.clear();
                          _liters = 0.0;
                          _totalPrice = 0;
                          _backendPricing = null;
                        }
                      });
                      _calculatePricingLocal();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_isInputLiters
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      side: BorderSide(
                        color: !_isInputLiters
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Berdasarkan Rupiah',
                      style: TextStyle(
                        color: !_isInputLiters
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _isInputLiters ? 'Liter Pembelian' : 'Nominal Pembelian (Rupiah)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                _isInputLiters
                    ? DecimalTextInputFormatter(decimalRange: 2)
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: _isInputLiters ? null : 'Rp ',
                suffixIcon: _isCalculatingPricing
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                suffixText: _isInputLiters && !_isCalculatingPricing ? ' Liter' : null,
              ),
            ),
            if (pricing != null &&
                pricing.isSubsidizedFuel &&
                pricing.usesMixedPricing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Pembelian ini akan dibagi menjadi ${pricing.subsidizedLiters.toStringAsFixed(2).replaceAll('.', ',')}L harga subsidi dan ${pricing.nonSubsidizedLiters.toStringAsFixed(2).replaceAll('.', ',')}L harga normal.',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (!_isInputLiters) ...[
              Row(
                children: [
                  Text(
                    'Estimasi Volume',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_liters.toStringAsFixed(2).replaceAll('.', ',')} Liter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (pricing != null && pricing.isSubsidizedFuel) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    if (pricing.subsidizedLiters > 0)
                      _PricingRow(
                        label: 'Porsi subsidi',
                        value:
                            '${pricing.subsidizedLiters.toStringAsFixed(2).replaceAll('.', ',')} L x ${_formatCurrency((pricing.subsidizedPricePerLiter ?? 0).round())}',
                      ),
                    if (pricing.subsidizedLiters > 0 &&
                        pricing.nonSubsidizedLiters > 0)
                      const SizedBox(height: 8),
                    if (pricing.nonSubsidizedLiters > 0)
                      _PricingRow(
                        label: 'Porsi normal',
                        value:
                            '${pricing.nonSubsidizedLiters.toStringAsFixed(2).replaceAll('.', ',')} L x ${_formatCurrency(pricing.marketPricePerLiter.round())}',
                      ),
                    if (_selectedFuelTypeIsSubsidized &&
                        pricing.usesMarketPriceOnly &&
                        _getPricingWarningText().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _getPricingWarningText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: switch (_accountStatus) {
                            'QUOTA_EXHAUSTED' => const Color(0xFFB56A00),
                            'NOT_ELIGIBLE'    => const Color(0xFF757575),
                            _                 => AppColors.statusCritical,
                          },
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Text(
                  'Total Harga',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCurrency(_totalPrice),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed
                    ? () {
                        final TransactionDraft draft = TransactionDraft(
                          userName: buyerName,
                          userNik: buyerNik,
                          plate: _plateController.text.trim().toUpperCase(),
                          fuel: _selectedFuelType?['name'] ?? '-',
                          fuelTypeId: _selectedFuelType?['id'] ?? '',
                          liters: _liters,
                          total: _totalPrice,
                          isPinActive: widget.isPinActive,
                          category: widget.vehicle.category,
                          pricingBreakdown:
                              pricing ??
                              FuelPricingBreakdown.fromLiters(
                                liters: _liters,
                                marketPricePerLiter: 0.0,
                                subsidizedPricePerLiter: null,
                                isSubsidizedFuel: false,
                                isEligibleForSubsidy: false,
                                remainingQuota: 0.0,
                              ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(draft: draft),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed
                      ? AppColors.primary
                      : Colors.grey,
                ),
                child: const Text('Lanjut Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FuelChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FuelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = isSelected ? AppColors.primary : AppColors.surface;
    final Color textColor = isSelected ? Colors.white : AppColors.textPrimary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }
    // Check if the input conforms to optional digits, followed by optional . or , and up to decimalRange digits
    final RegExp regex = RegExp('^\\d*([\\.,]\\d{0,$decimalRange})?\$');
    if (regex.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}
