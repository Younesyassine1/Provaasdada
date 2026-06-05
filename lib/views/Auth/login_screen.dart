// ============================================================
// FILE: login_screen.dart
// ============================================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/flag_language_button.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _eseguiLogin(Lingua linguaAttuale) async {
    final authCtrl = ref.read(authProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTesti.get('err_campi_vuoti', linguaAttuale))),
      );
      return;
    }

    final successo = await authCtrl.login(email: email, password: password);

    if (!mounted) return;

    if (!successo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTesti.get('err_credenziali_errate', linguaAttuale)),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Navigazione gestita dallo StreamBuilder in main.dart
  }

  @override
  Widget build(BuildContext context) {
    final linguaCtrl = ref.watch(linguaProvider);

    return ValueListenableBuilder<Lingua>(
      valueListenable: linguaCtrl.linguaCorrente,
      builder: (context, linguaAttuale, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E7D32), Color(0xFF0B210B)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlagLanguageButton(linguaAttuale: linguaAttuale),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.eco, size: 80, color: Colors.white),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'FloraLens',
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 40),
                                  CustomTextField(
                                    hintTesto: AppTesti.get('auth_email', linguaAttuale),
                                    icona: Icons.email_outlined,
                                    controller: _emailController,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    hintTesto: AppTesti.get('auth_password', linguaAttuale),
                                    icona: Icons.lock_outline,
                                    isPassword: true,
                                    controller: _passwordController,
                                  ),
                                  const SizedBox(height: 30),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: ref.read(authProvider).isLoading,
                                    builder: (context, isLoading, _) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF2E7D32),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          ),
                                          onPressed: isLoading ? null : () => _eseguiLogin(linguaAttuale),
                                          child: isLoading
                                              ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                                              : Text(
                                            AppTesti.get('btn_accedi', linguaAttuale),
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    ),
                                    child: Text(
                                      AppTesti.get('auth_non_hai_account', linguaAttuale) +
                                          AppTesti.get('btn_registrati', linguaAttuale),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}