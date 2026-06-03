import 'package:flutter/material.dart';
import 'package:psadassa/views/recognition_screen.dart';
import '../core/utils/app_strings.dart';
import '../controllers/language_controller.dart';
import 'my_plants_screen.dart'; // Assicurati di usare il nome in inglese se l'hai rinominato!
import 'widgets/menu_button.dart';
import 'widgets/flag_language_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. IL CERVELLO DELLA LINGUA
  final LinguaController _linguaController = LinguaController();

  // --- I PONTI VERSO LA LOGICA E LA NAVIGAZIONE ---

  void _apriRiconoscimento() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecognitionScreen()),
    );
  }

  void _apriMappaFiorai() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modulo in costruzione!')));
  }

  void _apriLeMiePiante() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPlantsScreen()), // Usa il nome corretto della tua classe
    );
  }

  // --- COSTRUZIONE DELLA UI ---

  @override
  Widget build(BuildContext context) {
    // 2. AVVOLGIAMO TUTTO NELL'ASCOLTATORE REATTIVO
    return ValueListenableBuilder<Lingua>(
      valueListenable: _linguaController.linguaCorrente,
      builder: (context, linguaAttuale, child) {

        // Ora usiamo "linguaAttuale" in tutta la pagina. Se cambia, Flutter ridisegna tutto da qui in giù!
        return Scaffold(
          backgroundColor: const Color(0xFFE0E5EC),
          body: Column(
            children: [
              _buildHeader(linguaAttuale),
              Expanded(child: _buildMenuPrincipale(context, linguaAttuale)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Lingua linguaAttuale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌱 FloraLens',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              // 3. IL NUOVO BOTTONE BANDIERA!
              FlagLanguageButton(linguaAttuale: linguaAttuale),

            ],
          ),
          const SizedBox(height: 5),
          Text(
            AppTesti.get('dash_saluto', linguaAttuale),
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPrincipale(BuildContext context, Lingua linguaAttuale) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          MenuButton(
            icona: '📷',
            titolo: AppTesti.get('btn_riconoscimento', linguaAttuale),
            sottotitolo: linguaAttuale == Lingua.it ? 'Identifica una pianta' : 'Identify a plant', // Esempio di traduzione inline al volo
            onTap: _apriRiconoscimento,
          ),
          const SizedBox(height: 15),

          MenuButton(
            icona: '📍',
            titolo: AppTesti.get('btn_trova_fioraio', linguaAttuale),
            sottotitolo: linguaAttuale == Lingua.it ? 'Cerca vivai vicini' : 'Search nearby nurseries',
            onTap: _apriMappaFiorai,
          ),
          const SizedBox(height: 15),

          MenuButton(
            icona: '🪴',
            titolo: AppTesti.get('btn_le_mie_piante', linguaAttuale),
            sottotitolo: linguaAttuale == Lingua.it ? 'Vedi la tua serra locale' : 'View your local greenhouse',
            onTap: _apriLeMiePiante,
          ),

          const Spacer(),

          _buildWeatherBanner(linguaAttuale),
        ],
      ),
    );
  }

  Widget _buildWeatherBanner(Lingua linguaAttuale) {
    // Semplice if per tradurre il banner statico
    final bool isIt = linguaAttuale == Lingua.it;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Color(0xFF4CAF50), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              isIt ? '🌧️ Aggiornamento Meteo Locale' : '🌧️ Local Weather Update',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))
          ),
          const SizedBox(height: 5),
          Text(
            isIt
                ? 'Sta piovendo nella tua posizione. I promemoria per le piante esterne sono stati posticipati.'
                : 'It is raining in your location. Reminders for outdoor plants have been postponed.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }
}