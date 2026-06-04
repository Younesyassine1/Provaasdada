import 'package:flutter/foundation.dart';
import '../core/network/meteo_facade.dart';

class MeteoController {
  final MeteoFacade _meteoFacade = MeteoFacade();

  // true = piove, false = non piove, null = sto caricando
  final ValueNotifier<bool?> pioveOggi = ValueNotifier<bool?>(null);

  Future<void> verificaMeteo() async {
    pioveOggi.value = null; // Avvia lo stato di caricamento

    final bool piovera = await _meteoFacade.controllaPioggiaOggi();

    pioveOggi.value = piovera;
  }
}