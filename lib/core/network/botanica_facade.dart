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

      // Creiamo una richiesta "Multipart" per inviare il file fisico dell'immagine
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('images', immagine.path))
        ..fields['organs'] = 'auto'; // L'AI di PlantNet rileverà automaticamente se è foglia/fiore

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonDati = jsonDecode(responseBody);

        // Estraiamo il miglior risultato dal JSON di PlantNet
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

  /// STEP 2: Interroga Trefle con il nome scientifico e delega la creazione alla Factory
  Future<Pianta?> ottieniDettagliDaTrefle(String nomeScientifico) async {
    try {
      final uri = Uri.parse('https://trefle.io/api/v1/plants/search?token=$APIKEYTREFLE&q=$nomeScientifico');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonDati = jsonDecode(response.body);

        if (jsonDati['data'] != null && jsonDati['data'].isNotEmpty) {
          // Prendiamo il primo risultato trovato da Trefle
          final piantaTrefle = jsonDati['data'][0];

          // LA MODIFICA: Usiamo la tua Factory difensiva!
          // Avvolgiamo il dato nel formato {'data': ...} proprio come si aspetta la tua classe Pianta.
          // In questo modo il Facade si lava le mani e la classe Pianta fa tutte le validazioni.
          return Pianta.fromTrefleJson(
            {'data': piantaTrefle},
            isDaEsterno: piantaTrefle['family_common_name'] != null, // Logica base di inferenza
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint("Errore in Trefle: $e");
      return null;
    }
  }
}