enum Lingua { it, en }

class AppTesti {
  static const Map<String, Map<Lingua, String>> _dizionario = {

    // --- AUTENTICAZIONE E REGISTRAZIONE ---
    'login_sottotitolo': {
      Lingua.it: 'La botanica a portata di mano',
      Lingua.en: 'Botany at your fingertips',
    },
    'btn_accedi': {
      Lingua.it: 'Accedi',
      Lingua.en: 'Login',
    },
    'btn_registrati': {
      Lingua.it: 'Registrati',
      Lingua.en: 'Sign Up',
    },
    'auth_non_hai_account': {
      Lingua.it: 'Non hai un account? ',
      Lingua.en: 'Don\'t have an account? ',
    },
    'auth_crea_account': {
      Lingua.it: 'Crea Account',
      Lingua.en: 'Create Account',
    },
    'auth_nome': {
      Lingua.it: 'Nome completo',
      Lingua.en: 'Full Name',
    },
    'auth_email': {
      Lingua.it: 'Email',
      Lingua.en: 'Email',
    },
    'auth_password': {
      Lingua.it: 'Password',
      Lingua.en: 'Password',
    },
    'auth_conferma_password': {
      Lingua.it: 'Conferma Password',
      Lingua.en: 'Confirm Password',
    },

    // --- MESSAGGI DI ERRORE E SUCCESSO (SNACKBAR) ---
    'err_campi_vuoti': {
      Lingua.it: 'Compila tutti i campi obbligatori!',
      Lingua.en: 'Please fill in all required fields!',
    },
    'err_email_non_valida': {
      Lingua.it: 'Inserisci un indirizzo email valido.',
      Lingua.en: 'Please enter a valid email address.',
    },
    'err_password_regex': {
      Lingua.it: 'La password deve avere almeno 8 caratteri, una maiuscola, un numero e un carattere speciale.',
      Lingua.en: 'Password must be at least 8 chars, include an uppercase, a number, and a special character.',
    },
    'err_password_no_match': {
      Lingua.it: 'Le password non coincidono!',
      Lingua.en: 'Passwords do not match!',
    },
    'err_credenziali_errate': {
      Lingua.it: 'Credenziali errate!',
      Lingua.en: 'Invalid credentials!',
    },
    'err_email_esistente': {
      Lingua.it: 'Email giÃ  registrata o errore imprevisto.',
      Lingua.en: 'Email already registered or unexpected error.',
    },
    'succ_registrazione': {
      Lingua.it: 'Registrazione completata! Ora puoi accedere.',
      Lingua.en: 'Registration complete! You can now log in.',
    },

    // --- DASHBOARD E PIANTE ---
    'dash_saluto': {
      Lingua.it: 'Ciao, bentornato nella tua serra!',
      Lingua.en: 'Hello, welcome back to your greenhouse!',
    },
    'btn_riconoscimento': {
      Lingua.it: 'Riconoscimento',
      Lingua.en: 'Identify',
    },
    'btn_trova_fioraio': {
      Lingua.it: 'Trova Fioraio',
      Lingua.en: 'Find Florist',
    },
    'btn_le_mie_piante': {
      Lingua.it: 'Le Mie Piante',
      Lingua.en: 'My Plants',
    },
    'btn_annaffia': {
      Lingua.it: 'Annaffia',
      Lingua.en: 'Water',
    },
    'btn_pulizia': {
      Lingua.it: 'Pulizia',
      Lingua.en: 'Clean',
    },
  };

  /// Restituisce il testo sicuro
  static String get(String chiave, Lingua linguaAttuale) {
    final traduzioniDellaChiave = _dizionario[chiave];
    if (traduzioniDellaChiave == null) return '[$chiave]';
    final testoTradotto = traduzioniDellaChiave[linguaAttuale];
    if (testoTradotto == null) return '[$chiave]';
    return testoTradotto;
  }
}