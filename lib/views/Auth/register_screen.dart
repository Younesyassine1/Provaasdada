import 'package:flutter/material.dart';
import '../../core/utils/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/flag_language_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller per i campi di testo
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confermaPasswordController = TextEditingController();

  // Istanze dei nostri gestori (Singleton)
  final AuthController _authController = AuthController();
  final LinguaController _linguaController = LinguaController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confermaPasswordController.dispose();
    super.dispose();
  }

  // --- LOGICA DI REGISTRAZIONE ---
  void _eseguiRegistrazione(Lingua linguaAttuale) async {
    final String nome = _nomeController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confermaPassword = _confermaPasswordController.text;

    // 1. Validazione Campi Vuoti
    if (nome.isEmpty || email.isEmpty || password.isEmpty) {
      _mostraMessaggio(AppTesti.get('err_campi_vuoti', linguaAttuale), isErrore: true);
      return;
    }

    // 2. Validazione Regex Email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _mostraMessaggio(AppTesti.get('err_email_non_valida', linguaAttuale), isErrore: true);
      return;
    }

    // 3. Validazione Regex Password (Min 8 char, 1 maiuscola, 1 minuscola, 1 numero, 1 char speciale)
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      _mostraMessaggio(AppTesti.get('err_password_regex', linguaAttuale), isErrore: true);
      return;
    }

    // 4. Validazione Corrispondenza Password
    if (password != confermaPassword) {
      _mostraMessaggio(AppTesti.get('err_password_no_match', linguaAttuale), isErrore: true);
      return;
    }

    // 5. Delega al Controller
    final successo = await _authController.registra(
      nome: nome,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (successo) {
      // Registrazione avvenuta: torna al Login
      _mostraMessaggio(AppTesti.get('succ_registrazione', linguaAttuale));
      Navigator.pop(context);
    } else {
      // Errore: l'email esiste giÃ
      _mostraMessaggio(AppTesti.get('err_email_esistente', linguaAttuale), isErrore: true);
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

          // AppBar con tasto indietro di default + bandiera affiancata
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
            // Inseriamo la bandiera subito dopo il tasto indietro annullando lo spazio standard
            titleSpacing: 0,
            centerTitle: false,
            title: Row(
              children: [
                FlagLanguageButton(linguaAttuale: linguaAttuale),
              ],
            ),
          ),

          // Corpo centrale
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Titolo
                  Text(
                    AppTesti.get('auth_crea_account', linguaAttuale),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 40),

                  // Form di registrazione
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
                    controller: _confermaPasswordController,
                  ),
                  const SizedBox(height: 40),

                  // Bottone Registrati dinamico
                  SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder<bool>(
                        valueListenable: _authController.isLoading,
                        builder: (context, isLoading, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isLoading ? null : () => _eseguiRegistrazione(linguaAttuale),
                            child: isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : Text(
                              AppTesti.get('btn_registrati', linguaAttuale),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
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