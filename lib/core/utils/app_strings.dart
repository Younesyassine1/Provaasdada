// ============================================================
// FILE: app_strings.dart
// ============================================================
enum Lingua { it, en }

class AppTesti {
  static const Map<String, Map<Lingua, String>> _dizionario = {

    // -------------------------------------------------------
    // AUTENTICAZIONE E REGISTRAZIONE
    // -------------------------------------------------------
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

    // -------------------------------------------------------
    // MESSAGGI DI ERRORE E SUCCESSO (SNACKBAR)
    // -------------------------------------------------------
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
      Lingua.it: 'Email già registrata o errore imprevisto.',
      Lingua.en: 'Email already registered or unexpected error.',
    },
    'err_generico': {
      Lingua.it: 'Si è verificato un errore:',
      Lingua.en: 'An error occurred:',
    },
    'succ_registrazione': {
      Lingua.it: 'Registrazione completata! Ora puoi accedere.',
      Lingua.en: 'Registration complete! You can now log in.',
    },
    'succ_pianta_aggiunta': {
      Lingua.it: 'Pianta aggiunta alla tua Serra!',
      Lingua.en: 'Plant added to your Greenhouse!',
    },
    'err_pianta_doppione': {
      Lingua.it: '🌿 Possiedi già questa pianta nella tua serra!',
      Lingua.en: '🌿 You already have this plant in your greenhouse!',
    },

    // -------------------------------------------------------
    // GENERICI / AZIONI COMUNI
    // -------------------------------------------------------
    'btn_riprova': {
      Lingua.it: 'Riprova',
      Lingua.en: 'Retry',
    },
    'btn_annulla': {
      Lingua.it: 'Annulla',
      Lingua.en: 'Cancel',
    },
    'btn_chiudi': {
      Lingua.it: 'Chiudi',
      Lingua.en: 'Close',
    },

    // -------------------------------------------------------
    // DASHBOARD
    // -------------------------------------------------------
    'dash_saluto': {
      Lingua.it: 'Ciao, ',
      Lingua.en: 'Hi, ',
    },
    'dash_saluto_emoji': {
      Lingua.it: '! 🌿',
      Lingua.en: '! 🌿',
    },
    'btn_riconoscimento': {
      Lingua.it: 'Riconoscimento',
      Lingua.en: 'Identify',
    },
    'btn_riconoscimento_sottotitolo': {
      Lingua.it: 'Identifica una pianta con AI',
      Lingua.en: 'Identify a plant with AI',
    },
    'btn_trova_fioraio': {
      Lingua.it: 'Trova Fioraio',
      Lingua.en: 'Find Florist',
    },
    'btn_trova_fioraio_sottotitolo': {
      Lingua.it: 'Esplora vivai vicini',
      Lingua.en: 'Explore nearby nurseries',
    },
    'btn_le_mie_piante': {
      Lingua.it: 'Le Mie Piante',
      Lingua.en: 'My Plants',
    },
    'btn_le_mie_piante_sottotitolo': {
      Lingua.it: 'Gestisci la tua serra',
      Lingua.en: 'Manage your greenhouse',
    },
    'btn_esci': {
      Lingua.it: 'Esci dall\'account',
      Lingua.en: 'Log out',
    },

    // -------------------------------------------------------
    // PIANTE — AZIONI CARD
    // -------------------------------------------------------
    'btn_annaffia': {
      Lingua.it: 'Annaffia',
      Lingua.en: 'Water',
    },
    'btn_pulizia': {
      Lingua.it: 'Pulizia',
      Lingua.en: 'Clean',
    },
    'pianta_esterno': {
      Lingua.it: 'Esterno',
      Lingua.en: 'Outdoor',
    },
    'pianta_interno': {
      Lingua.it: 'Interno',
      Lingua.en: 'Indoor',
    },
    'pianta_sposta_tooltip': {
      Lingua.it: 'Tocca per spostare la pianta',
      Lingua.en: 'Tap to move plant',
    },
    'no_piante': {
      Lingua.it: 'Non hai ancora piante!',
      Lingua.en: 'No plants yet!',
    },

    // -------------------------------------------------------
    // RICONOSCIMENTO BOTANICO
    // -------------------------------------------------------
    'recognition_titolo': {
      Lingua.it: 'Riconoscimento Botanico',
      Lingua.en: 'Botanical Recognition',
    },
    'recognition_scatta_foto': {
      Lingua.it: 'Scatta Foto',
      Lingua.en: 'Take a Photo',
    },
    'recognition_analisi_plantnet': {
      Lingua.it: 'Analisi PlantNet in corso...',
      Lingua.en: 'PlantNet analysis in progress...',
    },
    'recognition_ricerca_trefle': {
      Lingua.it: 'Ricerca dettagli su Trefle per: ',
      Lingua.en: 'Fetching details from Trefle for: ',
    },
    'recognition_impossibile': {
      Lingua.it: 'Impossibile riconoscere la pianta. Riprova con una foto più nitida.',
      Lingua.en: 'Unable to identify the plant. Try with a clearer photo.',
    },
    'recognition_completata': {
      Lingua.it: '🌿 Identificazione Completata!',
      Lingua.en: '🌿 Identification Complete!',
    },
    'recognition_dove_pianta': {
      Lingua.it: 'Dove posizionerai questa pianta?',
      Lingua.en: 'Where will you place this plant?',
    },
    'recognition_in_casa': {
      Lingua.it: 'In Casa',
      Lingua.en: 'Indoor',
    },
    'recognition_aperto': {
      Lingua.it: 'All\'aperto',
      Lingua.en: 'Outdoor',
    },
    'recognition_salva': {
      Lingua.it: 'Salva in Serra',
      Lingua.en: 'Save Plant',
    },

    // -------------------------------------------------------
    // FIORAI / MAPPA
    // -------------------------------------------------------
    'fiorai_titolo': {
      Lingua.it: 'Fiorai Vicini',
      Lingua.en: 'Nearby Florists',
    },
    'fiorai_caricamento': {
      Lingua.it: 'Ricerca fiorai su OpenStreetMap...',
      Lingua.en: 'Searching florists on OpenStreetMap...',
    },
    'fiorai_distanza': {
      Lingua.it: 'Distanza:',
      Lingua.en: 'Distance:',
    },

    // -------------------------------------------------------
    // METEO
    // -------------------------------------------------------
    'meteo_allerta_titolo': {
      Lingua.it: 'Allerta Meteo per Oggi:',
      Lingua.en: 'Weather Alert for Today:',
    },
    'meteo_allerta_testo': {
      Lingua.it: 'È prevista pioggia nella tua zona. Consigliamo di non annaffiare le tue piante da esterno!',
      Lingua.en: 'Rain is expected in your area. We advise against watering your outdoor plants!',
    },
  };

  /// Restituisce il testo per la chiave e la lingua richiesta.
  /// Se la chiave non esiste restituisce '[chiave]' per facilitare il debug.
  static String get(String chiave, Lingua linguaAttuale) {
    final traduzioniDellaChiave = _dizionario[chiave];
    if (traduzioniDellaChiave == null) return '[$chiave]';
    final testoTradotto = traduzioniDellaChiave[linguaAttuale];
    if (testoTradotto == null) return '[$chiave]';
    return testoTradotto;
  }
}