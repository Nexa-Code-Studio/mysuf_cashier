import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mock_data.dart';
import '../models/transaction_draft.dart';
import '../theme/theme.dart';
import 'payment_screen.dart';

class TransactionInputScreen extends StatefulWidget {
  final VehicleItem vehicle;

  const TransactionInputScreen({super.key, required this.vehicle});

  @override
  State<TransactionInputScreen> createState() => _TransactionInputScreenState();
}

class _TransactionInputScreenState extends State<TransactionInputScreen> {
  final TextEditingController _literController = TextEditingController();
  String? _selectedFuel;
  int _liters = 0;

  @override
  void initState() {
    super.initState();
    _literController.addListener(_handleLiterChange);
  }

  @override
  void dispose() {
    _literController.removeListener(_handleLiterChange);
    _literController.dispose();
    super.dispose();
  }

  void _handleLiterChange() {
    final int liters = int.tryParse(_literController.text.trim()) ?? 0;
    if (liters != _liters) {
      setState(() => _liters = liters);
    }
  }

  int get _total => _liters * 10000;

  bool get _isEligible => remainingQuotaLiters > 0;

  bool get _canProceed => _isEligible && _liters > 0 && _selectedFuel != null;

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

  @override
  Widget build(BuildContext context) {
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
                    currentUser.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                    widget.vehicle.plate,
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
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isEligible
                          ? 'Status: Eligible'
                          : 'Status: Tidak Tersedia',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _isEligible
                        ? 'Sisa Kuota ${remainingQuotaLiters} Liter'
                        : 'Kuota Habis',
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
            AbsorbPointer(
              absorbing: !_isEligible,
              child: Row(
                children: [
                  _FuelChip(
                    label: 'Pertalite',
                    isSelected: _selectedFuel == 'Pertalite',
                    onTap: () => setState(() => _selectedFuel = 'Pertalite'),
                  ),
                  const SizedBox(width: 12),
                  _FuelChip(
                    label: 'Bio Solar',
                    isSelected: _selectedFuel == 'Bio Solar',
                    onTap: () => setState(() => _selectedFuel = 'Bio Solar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Liter Pembelian',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            AbsorbPointer(
              absorbing: !_isEligible,
              child: TextField(
                controller: _literController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(hintText: '0'),
              ),
            ),
            const SizedBox(height: 16),
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
                  _formatCurrency(_total),
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
                          userName: currentUser.name,
                          userNik: currentUser.nik,
                          plate: widget.vehicle.plate,
                          fuel: _selectedFuel ?? '-',
                          liters: _liters,
                          total: _total,
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
          ),
          child: Center(
            child: Text(
              label,
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
