import 'package:flutter/foundation.dart';
import '../core/utils/app_strings.dart'; // L'import punta al nome file inglese

class LinguaController {
  // --- PATTERN SINGLETON ---
  static final LinguaController _instance = LinguaController._internal();
  factory LinguaController() => _instance;
  LinguaController._internal();

  // --- STATO REATTIVO ---
  // Default impostato su Italiano (Lingua.it)
  final ValueNotifier<Lingua> linguaCorrente = ValueNotifier<Lingua>(Lingua.it);

  // --- AZIONI ---

  /// Forza una lingua specifica
  void impostaLingua(Lingua nuovaLingua) {
    if (linguaCorrente.value != nuovaLingua) {
      linguaCorrente.value = nuovaLingua;
      debugPrint("Lingua cambiata in: ${nuovaLingua.name}");
    }
  }

  /// Inverte la lingua corrente (da IT a EN e viceversa)
  void toggleLingua() {
    if (linguaCorrente.value == Lingua.it) {
      linguaCorrente.value = Lingua.en;
    } else {
      linguaCorrente.value = Lingua.it;
    }
    debugPrint("Lingua switchata in: ${linguaCorrente.value.name}");
  }
}