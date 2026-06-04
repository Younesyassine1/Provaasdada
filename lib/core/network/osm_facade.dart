import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../models/entities/fioraio.dart';
import '../services/location_service.dart';

class OsmFacade {
  final LocationService _locationService = LocationService();

  Future<Map<String, dynamic>> trovaFioraiVicini() async {
    try {
      // 1. Otteniamo la posizione (Precisione alta per la mappa)
      final posizione = await _locationService.ottieniPosizioneAttuale(precisione: LocationAccuracy.high);

      // 2. Query Overpass QL: cerca "shop=florist" entro 5000 metri.
      // [out:json] restituisce JSON, 'out center' serve per trovare il centro geometrico degli edifici.
      final query = '''
        [out:json][timeout:25];
        nwr["shop"="florist"](around:5000,${posizione.latitude},${posizione.longitude});
        out center;
      ''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Errore di connessione a Overpass API.');
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
            debugPrint('Fioraio scartato: $e'); // Ignoriamo i nodi corrotti e salviamo gli altri
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
      debugPrint("Errore in OsmFacade: $e");
      rethrow;
    }
  }
}