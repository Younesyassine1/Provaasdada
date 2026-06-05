import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Importiamo il nostro nuovo servizio universale!
import '../services/location_service.dart';

class MeteoFacade {
  // Istanziamo il servizio
  final LocationService _locationService = LocationService();

  /// Controlla se è prevista pioggia nella giornata odierna (00:00 - 23:59)
  Future<bool> controllaPioggiaOggi() async {
    try {
      // 1. Deleghiamo il controllo GPS al servizio centralizzato.
      // Usa automaticamente la precisione 'medium' di default.
      final posizione = await _locationService.ottieniPosizioneAttuale();

      // 2. Interroga l'API di OpenMeteo (Gratuita e senza API Key)
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast'
              '?latitude=${posizione.latitude}&longitude=${posizione.longitude}'
              '&daily=precipitation_sum'
              '&timezone=auto'
              '&forecast_days=1'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Estraiamo la quantità di precipitazioni previste per oggi (in mm)
        final precipitazioni = data['daily']['precipitation_sum'][0] as double?;

        // Se pioverà anche solo 0.1 mm, restituiamo true!
        return (precipitazioni != null && precipitazioni > 0.0);
      }
      return false;

    } catch (e) {
      debugPrint("Errore MeteoFacade: $e");
      return false; // In caso di errore (es. no internet, no GPS), non mostriamo l'allarme
    }
  }
}