import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../models/entities/fioraio.dart';
import '../services/location_service.dart';

class LogisticaFacade {
  final LocationService _locationService = LocationService();

  Future<Map<String, dynamic>> trovaFioraiVicini() async {
    try {
      final posizione = await _locationService.ottieniPosizioneAttuale(precisione: LocationAccuracy.high);

      final String query = '''
        [out:json][timeout:25];
        nwr["shop"="florist"](around:5000,${posizione.latitude},${posizione.longitude});
        out center;
      ''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter');

      // --- LA SOLUZIONE ALL'ERRORE 406 ---
      // Aggiungiamo gli "Headers" per presentarci formalmente al server di OpenStreetMap.
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json', // Diciamo al server che accettiamo solo risposte JSON
          'User-Agent': 'FloraLensApp/1.0 (Flutter)', // Dichiariamo chi siamo (Regola d'oro di OSM)
        },
        body: 'data=${Uri.encodeComponent(query)}',
      );

      if (response.statusCode != 200) {
        debugPrint("ERRORE OVERPASS SERVER: ${response.statusCode} - ${response.body}");
        throw Exception('Errore ${response.statusCode} dal server mappe. Riprova tra poco.');
      }

      final jsonDati = jsonDecode(response.body);
      final elements = jsonDati['elements'] as List?;

      List<Fioraio> listaFiorai = [];

      if (elements != null && elements.isNotEmpty) {
        for (var item in elements) {
          try {
            final fioraioValidato = Fioraio.fromOverpassJson(
              item as Map<String, dynamic>,
              posizioneUtente: posizione,
            );
            listaFiorai.add(fioraioValidato);
          } catch (e) {
            debugPrint('Fioraio scartato per dati non validi: $e');
          }
        }
      }

      // Ordina dal più vicino al più lontano
      listaFiorai.sort((a, b) => a.distanzaKm.compareTo(b.distanzaKm));

      return {
        'posizioneUtente': posizione,
        'fiorai': listaFiorai,
      };

    } catch (e) {
      debugPrint("Errore nel LogisticaFacade: $e");
      rethrow;
    }
  }
}