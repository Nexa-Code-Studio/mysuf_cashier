import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const TransactionInputScreen({
    super.key,
    required this.vehicle,
    this.buyerName,
    this.buyerNik,
    this.isPinActive = false,
  });

  @override
  State<TransactionInputScreen> createState() => _TransactionInputScreenState();
}

class _TransactionInputScreenState extends State<TransactionInputScreen> {
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  final TextEditingController _inputController = TextEditingController();
  
  List<Map<String, dynamic>> _fuelTypes = [];
  Map<String, dynamic>? _selectedFuelType;
  bool _isLoadingFuels = true;
  String? _errorMessage;

  bool _isInputLiters = true;
  double _liters = 0.0;
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_handleInputChange);
    _loadFuels();
  }

  @override
  void dispose() {
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

  double _getPriceForFuel(Map<String, dynamic> fuel) {
    final bool eligible = _isEligible;
    final bool isSubsidized = fuel['subsidy_type'] == 'SUBSIDIZED';
    if (eligible && isSubsidized && fuel['subsidy_price_per_liter'] != null) {
      return fuel['subsidy_price_per_liter'].toDouble();
    }
    return fuel['price_per_liter'].toDouble();
  }

  void _handleInputChange() {
    final String text = _inputController.text.trim();
    if (_selectedFuelType == null) return;

    final double pricePerLiter = _getPriceForFuel(_selectedFuelType!);

    if (text.isEmpty) {
      setState(() {
        _liters = 0.0;
        _totalPrice = 0;
      });
      return;
    }

    if (_isInputLiters) {
      final String sanitizedText = text.replaceAll(',', '.');
      final double val = double.tryParse(sanitizedText) ?? 0.0;
      final int calculatedTotalPrice = (val * pricePerLiter).round();
      setState(() {
        _liters = val;
        _totalPrice = calculatedTotalPrice;
      });
    } else {
      final int val = int.tryParse(text) ?? 0;
      final double calculatedLiters = val / pricePerLiter;
      setState(() {
        _liters = calculatedLiters;
        _totalPrice = val;
      });
    }
  }

  void _selectFuelType(Map<String, dynamic> fuelType) {
    setState(() {
      _selectedFuelType = fuelType;
    });
    _handleInputChange();
  }

  double get _remainingQuota => widget.vehicle.remainingLiters;

  bool get _isEligible => widget.vehicle.isEligible && _remainingQuota > 0;

  bool get _isSubsidizedPurchase =>
      _isEligible &&
      _selectedFuelType != null &&
      _selectedFuelType!['subsidy_type'] == 'SUBSIDIZED';

  bool get _isQuotaExceeded =>
      _isSubsidizedPurchase && _liters > _remainingQuota;

  bool get _canProceed =>
      _liters > 0 &&
      !_isQuotaExceeded &&
      _selectedFuelType != null;

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
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final buyerName = widget.buyerName ?? currentUser.name;
    final buyerNik = widget.buyerNik ?? currentUser.nik;
    final Color statusColor = _isEligible
        ? AppColors.statusSafe
        : AppColors.statusCritical;
    final Color statusBackground = _isEligible
        ? const Color(0xFFE7F7EC)
        : const Color(0xFFFCE8E8);

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                  const SizedBox(height: 10),
                  Text(
                    'Kendaraan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.vehicle.plateNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isEligible
                          ? 'Status: Eligible'
                          : 'Status: Tidak Tersedia / Tidak Eligible',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _isEligible
                        ? 'Sisa Kuota ${_remainingQuota.toStringAsFixed(2).replaceAll('.', ',')} Liter'
                        : 'Kuota Habis / Tidak Ada',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
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
                                label: "${rowFuels[i]['name']}\n(${_formatCurrency(_getPriceForFuel(rowFuels[i]).round())}/L)",
                                isSelected: _selectedFuelType?['id'] == rowFuels[i]['id'],
                                onTap: () => _selectFuelType(rowFuels[i]),
                              ),
                            ]
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
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
                      final double pricePerLiter = _getPriceForFuel(_selectedFuelType!);
                      setState(() {
                        _isInputLiters = true;
                        if (_totalPrice > 0) {
                          final double calculatedLiters = _totalPrice / pricePerLiter;
                          final String formatted = calculatedLiters.toStringAsFixed(2);
                          _inputController.text = formatted.replaceAll('.', ',');
                          _liters = double.tryParse(formatted) ?? calculatedLiters;
                          _totalPrice = (_liters * pricePerLiter).round();
                        } else {
                          _inputController.clear();
                          _liters = 0.0;
                          _totalPrice = 0;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isInputLiters ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                      side: BorderSide(color: _isInputLiters ? AppColors.primary : AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Berdasarkan Liter',
                      style: TextStyle(
                        color: _isInputLiters ? AppColors.primary : AppColors.textPrimary,
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
                      final double pricePerLiter = _getPriceForFuel(_selectedFuelType!);
                      setState(() {
                        _isInputLiters = false;
                        if (_liters > 0) {
                          final int calculatedPrice = (_liters * pricePerLiter).round();
                          _inputController.text = calculatedPrice.toString();
                          _totalPrice = calculatedPrice;
                          _liters = calculatedPrice / pricePerLiter;
                        } else {
                          _inputController.clear();
                          _liters = 0.0;
                          _totalPrice = 0;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_isInputLiters ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                      side: BorderSide(color: !_isInputLiters ? AppColors.primary : AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Berdasarkan Rupiah',
                      style: TextStyle(
                        color: !_isInputLiters ? AppColors.primary : AppColors.textPrimary,
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                _isInputLiters
                    ? DecimalTextInputFormatter(decimalRange: 2)
                    : FilteringTextInputFormatter.digitsOnly
              ],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: _isInputLiters ? null : 'Rp ',
                suffixText: _isInputLiters ? ' Liter' : null,
              ),
            ),
            if (_isQuotaExceeded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Jumlah liter melebihi sisa kuota yang tersedia (${_remainingQuota.toStringAsFixed(2).replaceAll('.', ',')} Liter)!',
                  style: const TextStyle(
                    color: AppColors.statusCritical,
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
                          plate: widget.vehicle.plateNumber,
                          fuel: _selectedFuelType?['name'] ?? '-',
                          fuelTypeId: _selectedFuelType?['id'] ?? '',
                          liters: _liters,
                          total: _totalPrice,
                          isPinActive: widget.isPinActive,
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
