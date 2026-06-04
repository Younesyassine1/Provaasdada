import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/meteo_controller.dart';
import '../../controllers/language_controller.dart';
import '../../core/utils/app_strings.dart';

class MeteoBanner extends StatefulWidget {
  final Lingua linguaAttuale;

  const MeteoBanner({Key? key, required this.linguaAttuale}) : super(key: key);

  @override
  State<MeteoBanner> createState() => _MeteoBannerState();
}

class _MeteoBannerState extends State<MeteoBanner> {
  final MeteoController _meteoController = MeteoController();

  bool _visibile = true;
  Timer? _timerScomparsa;

  @override
  void initState() {
    super.initState();

    // 1. Ascoltiamo il controller: appena cambia valore, eseguiamo la nostra funzione
    _meteoController.pioveOggi.addListener(_gestisciTimer);

    // 2. Avviamo la richiesta API (o il Mocking temporaneo)
    _meteoController.verificaMeteo();
  }

  void _gestisciTimer() {
    // Se il controller ci conferma che oggi piove...
    if (_meteoController.pioveOggi.value == true) {
      // ...facciamo partire un conto alla rovescia di 6 secondi!
      _timerScomparsa = Timer(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _visibile = false; // Questo innescherà l'animazione di scomparsa
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // Pulizia della memoria fondamentale per evitare memory leak
    _meteoController.pioveOggi.removeListener(_gestisciTimer);
    _timerScomparsa?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _meteoController.pioveOggi,
      builder: (context, piove, child) {

        // 1. STATO: Caricamento in corso
        if (piove == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50))
              ),
            ),
          );
        }

        // 2. STATO: Non piove oggi (Invisibile)
        if (piove == false) {
          return const SizedBox.shrink();
        }

        final isIt = widget.linguaAttuale == Lingua.it;

        // 3. STATO: Pioverà oggi!
        // Usiamo AnimatedSize per far "collassare" il banner dolcemente quando _visibile diventa false.
        return AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: _visibile
              ? Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Color(0xFF4CAF50), width: 4)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌧️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      isIt ? 'Allerta Meteo per Oggi:' : 'Weather Alert for Today:',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  isIt
                      ? 'È prevista pioggia nella tua zona. Consigliamo di non annaffiare le tue piante da esterno!'
                      : 'Rain is expected in your area. We advise against watering your outdoor plants!',
                  style: const TextStyle(color: Color(0xFF388E3C), fontSize: 13),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(), // Quando scade il timer, l'AnimatedSize si restringe fino a scomparire
        );
      },
    );
  }
}