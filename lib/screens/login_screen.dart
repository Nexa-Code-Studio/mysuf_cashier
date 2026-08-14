import 'package:flutter/material.dart';
import '../app_session.dart';
import '../theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AppSession session = SessionScope.of(context);
    try {
      await session.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = SessionScope.of(context).isBusy;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6F7), Color(0xFFFFFFFF), Color(0xFFF4F4F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.local_gas_station_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Sidia Cashier',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk menggunakan akun operator SPBU yang sudah terdaftar di backend Sidia.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Email operator',
                                    hintText: 'andi@sidia.co.id',
                                  ),
                                  validator: (value) {
                                    final String text = value?.trim() ?? '';
                                    if (text.isEmpty) {
                                      return 'Email wajib diisi';
                                    }

                                    final bool isValid = RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(text);
                                    if (!isValid) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'PIN / kata sandi',
                                    hintText: 'Masukkan PIN atau password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'PIN / kata sandi wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isBusy ? null : _signIn,
                                    child: Text(
                                      isBusy ? 'Memproses Masuk...' : 'Masuk ke Kasir',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: isBusy
                                        ? null
                                        : () {
                                            setState(() {
                                              _emailController.text =
                                                  'so@sidia.id';
                                              _passwordController.text =
                                                  'subsidia123';
                                            });
                                          },
                                    icon: const Icon(Icons.auto_awesome,
                                        size: 18),
                                    label: const Text('Autofill Akun Demo'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scanner QR, NFC E-KTP, dan PIN e-wallet sudah aktif di aplikasi ini.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
