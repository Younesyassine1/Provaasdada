import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/language_controller.dart';
import '../core/utils/app_strings.dart';

// Importiamo i Widget personalizzati
import 'widgets/menu_button.dart';
import 'widgets/meteo_banner.dart';

// Importiamo le schermate funzionanti a cui portano i bottoni
import 'recognition_screen.dart';
import 'my_plants_screen.dart';
import 'fiorai_screen.dart'; // <-- IMPORTANTE: Aggiunto l'import per la mappa!

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LinguaController _linguaController = LinguaController();
  final AuthController _authController = AuthController();

  void _apriRiconoscimento() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RecognitionScreen()));
  }

  void _apriMiaSerra() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPlantsScreen()));
  }

  // LA FUNZIONE È STATA AGGIORNATA: Ora apre la vera schermata della mappa!
  void _apriMappaFiorai() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const FioraiScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lingua>(
      valueListenable: _linguaController.linguaCorrente,
      builder: (context, linguaAttuale, child) {

        final isIt = linguaAttuale == Lingua.it;
        final String primoNome = _authController.ottieniNomeFormattato(isIt);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                // 1. HEADER VERDE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FloraLens',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isIt ? 'Ciao $primoNome, bentornato!' : 'Hi $primoNome, welcome back!',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      // Bandierina Lingua in alto a destra
                      GestureDetector(
                        onTap: () {
                          _linguaController.linguaCorrente.value = isIt ? Lingua.en : Lingua.it;
                        },
                        child: Text(isIt ? '🇮🇹' : '🇬🇧', style: const TextStyle(fontSize: 26)),
                      ),
                    ],
                  ),
                ),

                // 2. CORPO DELLA DASHBOARD
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        MenuButton(
                          icona: '📷',
                          titolo: isIt ? 'Riconoscimento' : 'Recognition',
                          sottotitolo: isIt ? 'Identifica una pianta' : 'Identify a plant',
                          onTap: _apriRiconoscimento,
                        ),
                        const SizedBox(height: 15),

                        MenuButton(
                          icona: '📍',
                          titolo: isIt ? 'Trova Fioraio' : 'Find Florist',
                          sottotitolo: isIt ? 'Cerca vivai vicini' : 'Search nearby nurseries',
                          onTap: _apriMappaFiorai, // Collegato correttamente senza parametri extra
                        ),
                        const SizedBox(height: 15),

                        MenuButton(
                          icona: '🪴',
                          titolo: isIt ? 'Le Mie Piante' : 'My Plants',
                          sottotitolo: isIt ? 'Vedi la tua serra locale' : 'View your local greenhouse',
                          onTap: _apriMiaSerra,
                        ),

                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              await _authController.esci();
                            },
                            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                            label: Text(
                              isIt ? 'Esci dall\'account' : 'Log out',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // 3. WIDGET METEO DINAMICO
                        MeteoBanner(linguaAttuale: linguaAttuale),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}