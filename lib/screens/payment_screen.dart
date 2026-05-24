import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_draft.dart';
import '../theme/theme.dart';
import '../widgets/payment_method_card.dart';

class PaymentScreen extends StatelessWidget {
  final TransactionDraft draft;

  const PaymentScreen({super.key, required this.draft});

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

  void _completeTransaction(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil diselesaikan')),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _showEwalletSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _EwalletPinSheet(
          onVerify: () => _completeTransaction(context),
        );
      },
    );
  }

  Future<void> _showQrisDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('QRIS Pembayaran'),
          content: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 120,
              color: AppColors.primary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _completeTransaction(context);
              },
              child: const Text('Selesai & Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCashSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _CashSheet(
          total: draft.total,
          formatCurrency: _formatCurrency,
          onComplete: () => _completeTransaction(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Pembayaran',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
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
                  _InfoRow(label: 'Nama', value: draft.userName),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Plat', value: draft.plate),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Jenis BBM', value: draft.fuel),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Jumlah', value: '${draft.liters} Liter'),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        _formatCurrency(draft.total),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'E-Wallet KTP',
              subtitle: 'Wajib verifikasi PIN',
              onTap: () => _showEwalletSheet(context),
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.qr_code_2_outlined,
              title: 'QRIS',
              subtitle: 'Scan untuk pembayaran',
              onTap: () => _showQrisDialog(context),
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.payments_outlined,
              title: 'Tunai / Cash',
              subtitle: 'Pembayaran tunai',
              onTap: () => _showCashSheet(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Setelah verifikasi berhasil, transaksi akan langsung diselesaikan.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EwalletPinSheet extends StatefulWidget {
  final VoidCallback onVerify;

  const _EwalletPinSheet({required this.onVerify});

  @override
  State<_EwalletPinSheet> createState() => _EwalletPinSheetState();
}

class _EwalletPinSheetState extends State<_EwalletPinSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    final String pin = _pinController.text.trim();
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN e-wallet harus 6 digit')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    widget.onVerify();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verifikasi PIN E-Wallet KTP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan PIN 6 digit untuk menyelesaikan pembayaran dengan e-wallet KTP.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _verify(),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'PIN 6 digit',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verify,
                child: Text(_isVerifying ? 'Memverifikasi...' : 'Verifikasi PIN'),
              ),
            ),
            if (_isVerifying) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CashSheet extends StatefulWidget {
  final int total;
  final String Function(int value) formatCurrency;
  final VoidCallback onComplete;

  const _CashSheet({
    required this.total,
    required this.formatCurrency,
    required this.onComplete,
  });

  @override
  State<_CashSheet> createState() => _CashSheetState();
}

class _CashSheetState extends State<_CashSheet> {
  final TextEditingController _receivedController = TextEditingController();
  int _received = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  void _finish() {
    if (_received >= widget.total && !_isFinishing) {
      _isFinishing = true;
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int change = _received - widget.total;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nominal Uang Diterima',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _receivedController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  _received = int.tryParse(value) ?? 0;
                });
                if (_received >= widget.total) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _finish();
                    }
                  });
                }
              },
              onSubmitted: (_) => _finish(),
              decoration: const InputDecoration(
                hintText: 'Contoh: 100000',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kembalian: ${widget.formatCurrency(change < 0 ? 0 : change)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _received >= widget.total
                  ? 'Nominal cukup. Transaksi sedang diselesaikan...'
                  : 'Transaksi akan langsung selesai saat nominal yang diterima sudah cukup.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            if (_received < widget.total)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Menunggu nominal cukup'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}