import 'package:flutter/material.dart';
import '../../core/utils/app_strings.dart';
import '../../controllers/language_controller.dart';

class FlagLanguageButton extends StatelessWidget {
  final Lingua linguaAttuale;

  const FlagLanguageButton({Key? key, required this.linguaAttuale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Usiamo le emoji testuali: si adattano perfettamente come icone!
      icon: Text(
        linguaAttuale == Lingua.it ? '🇮🇹' : '🇬🇧',
        style: const TextStyle(fontSize: 26), // Dimensione della bandiera
      ),
      onPressed: () {
        // Al click, ordiniamo al Singleton globale di cambiare la lingua
        LinguaController().toggleLingua();
      },
      tooltip: linguaAttuale == Lingua.it ? 'Cambia in Inglese' : 'Switch to Italian',
    );
  }
}