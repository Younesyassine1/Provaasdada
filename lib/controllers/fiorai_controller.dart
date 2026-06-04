import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/network/logistica_facade.dart';
import '../models/entities/fioraio.dart';

class FioraiController {
  final LogisticaFacade _logisticaFacade = LogisticaFacade();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String?> errore = ValueNotifier<String?>(null);

  Position? posizioneAttuale;
  List<Fioraio> listaFiorai = [];

  Future<void> caricaDatiMappa() async {
    isLoading.value = true;
    errore.value = null;

    try {
      final dati = await _logisticaFacade.trovaFioraiVicini();
      posizioneAttuale = dati['posizioneUtente'];
      listaFiorai = dati['fiorai'];
    } catch (e) {
      errore.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
