import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_session.dart';
import '../models/transaction_draft.dart';
import '../theme/theme.dart';
import '../widgets/payment_method_card.dart';
import '../cashier/cashier_buyer_repository.dart';

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
    SessionScope.of(context).bumpCashierDataRevision();
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
          draft: draft,
          onVerify: () => _completeTransaction(context),
        );
      },
    );
  }

  Future<void> _executeWalletPaymentWithoutPin(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = CashierBuyerRepository();
      await repository.executeFuelPurchase(
        nik: draft.userNik,
        plateNumber: draft.plate,
        fuelTypeId: draft.fuelTypeId,
        liters: draft.liters,
        totalAmount: draft.total,
        paymentMethod: 'WALLET',
        pin: null,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Pop the progress dialog
      _completeTransaction(context);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Pop the progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi Gagal: ${e.toString().replaceFirst('Exception: ', '')}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  Future<void> _executeCashPayment(BuildContext context, int amountPaid) async {
    final repository = CashierBuyerRepository();
    await repository.executeFuelPurchase(
      nik: draft.userNik,
      plateNumber: draft.plate,
      fuelTypeId: draft.fuelTypeId,
      liters: draft.liters,
      totalAmount: draft.total,
      paymentMethod: 'CASH',
      amountPaid: amountPaid,
      pin: null,
    );
  }

  Future<void> _showXenditDialog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _QrisPaymentSheet(
          draft: draft,
          formatCurrency: _formatCurrency,
          onComplete: () => _completeTransaction(context),
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
          onSubmit: (amountPaid) => _executeCashPayment(context, amountPaid),
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
                  _InfoRow(
                    label: 'Jumlah',
                    value: '${draft.liters.toStringAsFixed(2)} Liter',
                  ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'E-Wallet KTP',
              subtitle: draft.isPinActive
                  ? 'Wajib verifikasi PIN'
                  : 'Pembayaran instan (Tanpa PIN)',
              onTap: () {
                if (draft.isPinActive) {
                  _showEwalletSheet(context);
                } else {
                  _executeWalletPaymentWithoutPin(context);
                }
              },
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.qr_code_2_outlined,
              title: 'Non Tunai / Xendit',
              subtitle: 'Buka payment link lalu tunggu status',
              onTap: () => _showXenditDialog(context),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EwalletPinSheet extends StatefulWidget {
  final TransactionDraft draft;
  final VoidCallback onVerify;

  const _EwalletPinSheet({required this.draft, required this.onVerify});

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

    try {
      final repository = CashierBuyerRepository();
      await repository.executeFuelPurchase(
        nik: widget.draft.userNik,
        plateNumber: widget.draft.plate,
        fuelTypeId: widget.draft.fuelTypeId,
        liters: widget.draft.liters,
        totalAmount: widget.draft.total,
        paymentMethod: 'WALLET',
        pin: pin,
      );

      if (!mounted) return;
      widget.onVerify();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi Gagal: ${e.toString().replaceFirst('Exception: ', '')}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
    }
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan PIN 6 digit untuk menyelesaikan pembayaran dengan e-wallet KTP.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
              decoration: const InputDecoration(hintText: 'PIN 6 digit'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verify,
                child: Text(
                  _isVerifying ? 'Memverifikasi...' : 'Verifikasi PIN',
                ),
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

class _QrisPaymentSheet extends StatefulWidget {
  final TransactionDraft draft;
  final String Function(int value) formatCurrency;
  final VoidCallback onComplete;

  const _QrisPaymentSheet({
    required this.draft,
    required this.formatCurrency,
    required this.onComplete,
  });

  @override
  State<_QrisPaymentSheet> createState() => _QrisPaymentSheetState();
}

class _QrisPaymentSheetState extends State<_QrisPaymentSheet> {
  final CashierBuyerRepository _repository = CashierBuyerRepository();
  Timer? _timer;

  bool _isLoading = true;
  bool _isChecking = false;
  String _status = 'PENDING';
  String? _transactionId;
  String? _providerReferenceId;
  String? _paymentLinkUrl;
  String? _errorMessage;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _createQrisPayment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _createQrisPayment() async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _status = 'PENDING';
      _transactionId = null;
      _providerReferenceId = null;
      _paymentLinkUrl = null;
      _expiresAt = null;
    });

    try {
      final result = await _repository.createXenditFuelPurchase(
        nik: widget.draft.userNik,
        plateNumber: widget.draft.plate,
        fuelTypeId: widget.draft.fuelTypeId,
        liters: widget.draft.liters,
        totalAmount: widget.draft.total,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _transactionId = result['transaction_id'] as String?;
        _providerReferenceId = result['provider_reference_id'] as String?;
        _paymentLinkUrl = result['payment_link_url'] as String?;
        _status = ((result['status'] as String?) ?? 'PENDING').toUpperCase();
        _expiresAt = _parseDateTime(result['expires_at'] as String?);
      });

      if (_paymentLinkUrl == null || _transactionId == null) {
        setState(() {
          _errorMessage = 'Response Xendit dari server tidak valid.';
        });
        return;
      }

      await _openPaymentLink();

      if (_status == 'PENDING') {
        _startPolling();
      } else if (_status == 'PAID') {
        widget.onComplete();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkStatus();
    });
  }

  Future<void> _openPaymentLink() async {
    if (_paymentLinkUrl == null) return;

    final uri = Uri.parse(_paymentLinkUrl!);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka halaman pembayaran.')),
      );
    }
  }

  Future<void> _checkStatus() async {
    if (_isChecking || _transactionId == null) return;

    setState(() => _isChecking = true);
    try {
      final result = await _repository.pollXenditFuelPurchaseStatus(
        _transactionId!,
      );
      final status = ((result['status'] as String?) ?? 'PENDING').toUpperCase();

      if (!mounted) return;

      setState(() {
        _status = status;
        _expiresAt = _parseDateTime(result['expires_at'] as String?);
        _errorMessage = null;
      });

      if (status == 'PAID') {
        _timer?.cancel();
        widget.onComplete();
      } else if (status == 'FAILED' || status == 'EXPIRED') {
        _timer?.cancel();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  String _statusLabel() {
    switch (_status) {
      case 'PAID':
        return 'Pembayaran berhasil';
      case 'FAILED':
        return 'Pembayaran gagal';
      case 'EXPIRED':
        return 'Payment link kedaluwarsa';
      default:
        return 'Menunggu pembayaran';
    }
  }

  Color _statusColor() {
    switch (_status) {
      case 'PAID':
        return AppColors.statusSafe;
      case 'FAILED':
      case 'EXPIRED':
        return AppColors.statusCritical;
      default:
        return AppColors.primary;
    }
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
              'Xendit Pembayaran',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Buka payment link Xendit, lalu status pembayaran akan diperiksa otomatis.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Container(
                      width: 220,
                      height: 220,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 96,
                        color: AppColors.primary,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.formatCurrency(widget.draft.total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusLabel(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _statusColor(),
                    ),
                  ),
                  if (_expiresAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Berlaku sampai ${_expiresAt!.hour.toString().padLeft(2, '0')}:${_expiresAt!.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (_providerReferenceId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ref: $_providerReferenceId',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.statusCritical,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_paymentLinkUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openPaymentLink,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Buka Kembali Payment Link'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isLoading || _isChecking || _transactionId == null)
                    ? null
                    : _checkStatus,
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                label: const Text('Cek Status'),
              ),
            ),
            if (!_isLoading &&
                (_status == 'FAILED' ||
                    _status == 'EXPIRED' ||
                    _errorMessage != null)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _createQrisPayment,
                  child: const Text('Buat Ulang Pembayaran'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashSheet extends StatefulWidget {
  final int total;
  final String Function(int value) formatCurrency;
  final Future<void> Function(int amountPaid) onSubmit;
  final VoidCallback onComplete;

  const _CashSheet({
    required this.total,
    required this.formatCurrency,
    required this.onSubmit,
    required this.onComplete,
  });

  @override
  State<_CashSheet> createState() => _CashSheetState();
}

class _CashSheetState extends State<_CashSheet> {
  final TextEditingController _receivedController = TextEditingController();
  int _received = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_received < widget.total || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(_received);
      if (!mounted) return;
      widget.onComplete();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi Gagal: ${e.toString().replaceFirst('Exception: ', '')}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
              },
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: 'Contoh: 100000'),
            ),
            const SizedBox(height: 16),
            Text(
              'Kembalian: ${widget.formatCurrency(change < 0 ? 0 : change)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              _received >= widget.total
                  ? 'Nominal cukup. Tekan tombol untuk menyelesaikan transaksi.'
                  : 'Masukkan nominal hingga cukup untuk menyelesaikan transaksi.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_received >= widget.total && !_isSubmitting)
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_received >= widget.total && !_isSubmitting)
                      ? AppColors.primary
                      : Colors.grey,
                ),
                child: Text(
                  _isSubmitting
                      ? 'Memproses transaksi...'
                      : (_received >= widget.total
                            ? 'Selesaikan Pembayaran Tunai'
                            : 'Menunggu nominal cukup'),
                ),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
