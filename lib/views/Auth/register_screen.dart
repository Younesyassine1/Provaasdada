// ============================================================
// FILE: register_screen.dart
// ============================================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/flag_language_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confermaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confermaController.dispose();
    super.dispose();
  }

  void _eseguiRegistrazione(Lingua linguaAttuale) async {
    final authCtrl = ref.read(authProvider);

    if (_nomeController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confermaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTesti.get('err_campi_vuoti', linguaAttuale))),
      );
      return;
    }

    if (_passwordController.text != _confermaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTesti.get('err_password_no_match', linguaAttuale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final successo = await authCtrl.registra(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (successo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTesti.get('succ_registrazione', linguaAttuale)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      // Navigazione finale alla Dashboard gestita dallo StreamBuilder in main.dart
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTesti.get('err_email_esistente', linguaAttuale)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final linguaCtrl = ref.watch(linguaProvider);

    return ValueListenableBuilder<Lingua>(
      valueListenable: linguaCtrl.linguaCorrente,
      builder: (context, linguaAttuale, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
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
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
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
                                  Text(
                                    AppTesti.get('auth_crea_account', linguaAttuale),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  CustomTextField(
                                    hintTesto: AppTesti.get('auth_nome', linguaAttuale),
                                    icona: Icons.person_outline,
                                    controller: _nomeController,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    hintTesto: AppTesti.get('auth_email', linguaAttuale),
                                    icona: Icons.email_outlined,
                                    controller: _emailController,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    hintTesto: AppTesti.get('auth_password', linguaAttuale),
                                    icona: Icons.lock_outline,
                                    isPassword: true,
                                    controller: _passwordController,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    hintTesto: AppTesti.get('auth_conferma_password', linguaAttuale),
                                    icona: Icons.lock_reset,
                                    isPassword: true,
                                    controller: _confermaController,
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
                                          onPressed: isLoading ? null : () => _eseguiRegistrazione(linguaAttuale),
                                          child: isLoading
                                              ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                                              : Text(
                                            AppTesti.get('btn_registrati', linguaAttuale),
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
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