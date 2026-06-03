import 'package:flutter/material.dart';
import '../../core/utils/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/flag_language_button.dart';
import '../dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller per i campi di testo
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Istanze dei nostri gestori (Singleton)
  final AuthController _authController = AuthController();
  final LinguaController _linguaController = LinguaController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGICA DI ACCESSO ---
  void _eseguiLogin(Lingua linguaAttuale) async {
    final String emailInserita = _emailController.text.trim();
    final String passwordInserita = _passwordController.text;

    // Controllo campi vuoti
    if (emailInserita.isEmpty || passwordInserita.isEmpty) {
      _mostraMessaggio(AppTesti.get('err_campi_vuoti', linguaAttuale), isErrore: true);
      return;
    }

    // Delega al Controller
    final successo = await _authController.login(
      email: emailInserita,
      password: passwordInserita,
    );

    if (!mounted) return;

    if (successo) {
      // Login effettuato con successo: Navigazione verso la Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Credenziali errate
      _mostraMessaggio(AppTesti.get('err_credenziali_errate', linguaAttuale), isErrore: true);
    }
  }

  // Helper per mostrare messaggi (SnackBar)
  void _mostraMessaggio(String messaggio, {bool isErrore = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio, style: const TextStyle(color: Colors.white)),
        backgroundColor: isErrore ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- INTERFACCIA GRAFICA ---
  @override
  Widget build(BuildContext context) {
    // Ascoltatore Reattivo della Lingua
    return ValueListenableBuilder<Lingua>(
      valueListenable: _linguaController.linguaCorrente,
      builder: (context, linguaAttuale, child) {

        return Scaffold(
          backgroundColor: const Color(0xFFE0E5EC),

          // AppBar trasparente con la bandiera in alto a sinistra
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: FlagLanguageButton(linguaAttuale: linguaAttuale),
          ),

          // Corpo centrale
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 20),

                  // Titolo
                  const Text(
                    'FloraLens',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  Text(
                    AppTesti.get('login_sottotitolo', linguaAttuale),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 50),

                  // Form di input
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
                  const SizedBox(height: 30),

                  // Bottone Accedi dinamico
                  SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder<bool>(
                        valueListenable: _authController.isLoading,
                        builder: (context, isLoading, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                            ),
                            onPressed: isLoading ? null : () => _eseguiLogin(linguaAttuale),
                            child: isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : Text(
                              AppTesti.get('btn_accedi', linguaAttuale),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link per la registrazione
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      '${AppTesti.get('auth_non_hai_account', linguaAttuale)}${AppTesti.get('btn_registrati', linguaAttuale)}',
                      style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
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