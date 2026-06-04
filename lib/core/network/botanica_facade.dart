import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/entities/pianta.dart';
import '../../constants.dart';

class BotanicaFacade {

  /// STEP 1: Invia la foto a PlantNet e ottiene il nome scientifico
  Future<String?> identificaDaFoto(File immagine) async {
    try {
      final uri = Uri.parse('https://my-api.plantnet.org/v2/identify/all?api-key=$APIKEYPLANT');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('images', immagine.path))
        ..fields['organs'] = 'auto';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonDati = jsonDecode(responseBody);

        if (jsonDati['results'] != null && jsonDati['results'].isNotEmpty) {
          final migliorRisultato = jsonDati['results'][0];
          return migliorRisultato['species']['scientificNameWithoutAuthor'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Errore in PlantNet: $e");
      return null;
    }
  }

  /// STEP 2: Interroga Trefle in due fasi per ottenere i dati reali di crescita (growth)
  Future<Pianta?> ottieniDettagliDaTrefle(String nomeScientifico) async {
    try {
      // Fase A: Ricerca generica per ottenere lo "slug" (l'ID univoco interno di Trefle)
      final uriRicerca = Uri.parse('https://trefle.io/api/v1/species/search?token=$APIKEYTREFLE&q=$nomeScientifico');
      final responseRicerca = await http.get(uriRicerca);

      if (responseRicerca.statusCode == 200) {
        final jsonRicerca = jsonDecode(responseRicerca.body);

        if (jsonRicerca['data'] != null && jsonRicerca['data'].isNotEmpty) {
          final slug = jsonRicerca['data'][0]['slug'];

          // Fase B: Chiamata di dettaglio profondo (contiene i dati reali su acqua e luce)
          final uriDettaglio = Uri.parse('https://trefle.io/api/v1/species/$slug?token=$APIKEYTREFLE');
          final responseDettaglio = await http.get(uriDettaglio);

          if (responseDettaglio.statusCode == 200) {
            final jsonDettaglio = jsonDecode(responseDettaglio.body);

            return Pianta.fromTrefleJson(
              jsonDettaglio,
              isDaEsterno: false, // Inizializzato di default, l'utente lo cambierÃ  al salvataggio
            );
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint("Errore in Trefle: $e");
      return null;
    }
  }
}