import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_session.dart';
import '../theme/theme.dart';
import 'vehicle_selection_screen.dart';
import '../cashier/cashier_buyer_repository.dart';

class ManualNikScreen extends StatefulWidget {
  const ManualNikScreen({super.key});

  @override
  State<ManualNikScreen> createState() => _ManualNikScreenState();
}

class _ManualNikScreenState extends State<ManualNikScreen> {
  final TextEditingController _controller = TextEditingController();
  final CashierBuyerRepository _buyerRepository = CashierBuyerRepository();
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleChange() {
    final bool isValid = _controller.text.trim().length == 16;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.background),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan NIK Pelanggan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 16,
              decoration: const InputDecoration(
                hintText: 'Contoh: 3201234567890001',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid && !_isLoading
                    ? () async {
                        setState(() => _isLoading = true);
                        try {
                          final lookupResult = await _buyerRepository.lookupBuyerByNfc(_controller.text.trim());
                          if (!mounted) return;
                          SessionScope.of(context).bumpCashierDataRevision();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VehicleSelectionScreen(lookupResult: lookupResult),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          SessionScope.of(context).bumpCashierDataRevision();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mencari data: ${e.toString().replaceFirst('Exception: ', '')}'),
                              backgroundColor: Colors.red[800],
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? AppColors.primary : Colors.grey,
                ),
                child: Text(_isLoading ? 'Mencari...' : 'Cari Data'),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
