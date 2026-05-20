import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_draft.dart';
import '../theme/theme.dart';
import '../widgets/payment_method_card.dart';

class PaymentScreen extends StatefulWidget {
  final TransactionDraft draft;

  const PaymentScreen({super.key, required this.draft});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _methodCompleted = false;

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

  void _markCompleted() {
    if (!_methodCompleted) {
      setState(() => _methodCompleted = true);
    }
  }

  Future<void> _showEwalletSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'Tempelkan E-KTP untuk Verifikasi Saldo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _markCompleted();
                  },
                  child: const Text('Konfirmasi Potong Saldo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showQrisDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('QRIS Pembayaran'),
          content: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                _markCompleted();
              },
              child: const Text('Selesai & Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCashSheet() async {
    int received = 0;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final int change = received - widget.draft.total;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32 + MediaQuery.of(sheetContext).viewInsets.bottom,
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setModalState(() {
                        received = int.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 100000',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kembalian: ${_formatCurrency(change < 0 ? 0 : change)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: received >= widget.draft.total
                          ? () {
                              Navigator.pop(sheetContext);
                              _markCompleted();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: received >= widget.draft.total
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              ),
            );
          },
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
                  _InfoRow(label: 'Nama', value: widget.draft.userName),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Plat', value: widget.draft.plate),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Jenis BBM', value: widget.draft.fuel),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Jumlah',
                    value: '${widget.draft.liters} Liter',
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
                        _formatCurrency(widget.draft.total),
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
              subtitle: 'Saldo Rp 500.000',
              onTap: _showEwalletSheet,
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.qr_code_2_outlined,
              title: 'QRIS',
              subtitle: 'Scan untuk pembayaran',
              onTap: _showQrisDialog,
            ),
            const SizedBox(height: 12),
            PaymentMethodCard(
              icon: Icons.payments_outlined,
              title: 'Tunai / Cash',
              subtitle: 'Pembayaran tunai',
              onTap: _showCashSheet,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _methodCompleted
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaksi berhasil diselesaikan'),
                          ),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _methodCompleted
                      ? AppColors.primary
                      : Colors.grey,
                ),
                child: const Text('Selesaikan Transaksi'),
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
