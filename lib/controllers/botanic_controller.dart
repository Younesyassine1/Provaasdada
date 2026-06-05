import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/network/botanica_facade.dart';
import '../models/entities/pianta.dart';
import '../core/utils/app_strings.dart';

class BotanicaController {
  final BotanicaFacade _botanicaFacade = BotanicaFacade();

  // Stati reattivi per la UI
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<File?> immagineCatturata = ValueNotifier<File?>(null);
  final ValueNotifier<Pianta?> piantaIdentificata = ValueNotifier<Pianta?>(null);
  final ValueNotifier<String> messaggioStato = ValueNotifier<String>("");

  /// Imposta l'immagine appena scattata e resetta i dati precedenti
  void impostaImmagine(File immagine) {
    immagineCatturata.value = immagine;
    piantaIdentificata.value = null;
    messaggioStato.value = "";
  }

  /// Avvia l'intera sequenza di riconoscimento (PlantNet -> Trefle)
  Future<void> avviaRiconoscimento(Lingua lingua) async {
    if (immagineCatturata.value == null) return;

    isLoading.value = true;
    messaggioStato.value = AppTesti.get('recognition_analisi_plantnet', lingua);

    // 1. Chiamata a PlantNet
    final nomeScientifico = await _botanicaFacade.identificaDaFoto(immagineCatturata.value!);

    if (nomeScientifico != null) {
      messaggioStato.value = '${AppTesti.get('recognition_ricerca_trefle', lingua)}$nomeScientifico...';

      // 2. Chiamata a Trefle
      final dettagli = await _botanicaFacade.ottieniDettagliDaTrefle(nomeScientifico);

      piantaIdentificata.value = dettagli;

      if (dettagli != null) {
        messaggioStato.value = AppTesti.get('recognition_completata', lingua);
      } else {
        messaggioStato.value = AppTesti.get('recognition_impossibile', lingua);
      }
    } else {
      messaggioStato.value = AppTesti.get('recognition_impossibile', lingua);
    }

    isLoading.value = false;
  }

  /// Pulisce lo stato per iniziare una nuova scansione
  void reset() {
    immagineCatturata.value = null;
    piantaIdentificata.value = null;
    messaggioStato.value = "";
    isLoading.value = false;
  }
}