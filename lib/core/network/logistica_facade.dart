import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../models/entities/fioraio.dart';

class LogisticaFacade {
  // TODO: Sostituite questa stringa con la vostra vera API Key di Google Cloud Platform
  static const String _googleApiKey = 'INSERISCI_API_KEY_GOOGLE_MAPS';

  /// Trova i fiorai entro un raggio di 5km e li ordina per distanza
  Future<List<Fioraio>> trovaFioraiVicini() async {
    try {
      // --- 1. GESTIONE PERMESSI E GPS ---

      // Controlliamo se il GPS del telefono è fisicamente acceso
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('I servizi di localizzazione sono spenti. Accendi il GPS.');
      }

      // Controlliamo i permessi dell'app
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission(); // Mostra il popup di sistema
        if (permission == LocationPermission.denied) {
          throw Exception('Permessi di localizzazione negati dall\'utente.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permessi negati permanentemente. Cambiali dalle impostazioni del telefono.');
      }

      // Tutto ok, otteniamo le coordinate dell'utente
      final Position posizioneAttuale = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // --- 2. CHIAMATA A GOOGLE PLACES API ---

      // Cerchiamo i negozi di tipo "florist" (fiorai/vivai) in un raggio di 5000 metri (5km)
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
              '?location=${posizioneAttuale.latitude},${posizioneAttuale.longitude}'
              '&radius=5000'
              '&type=florist'
              '&key=$_googleApiKey'
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Errore di connessione ai server di Google Maps.');
      }

      final jsonDati = jsonDecode(response.body);
      final results = jsonDati['results'] as List?;

      // Se non ci sono fiorai nel raggio di 5km, restituiamo una lista vuota
      if (results == null || results.isEmpty) {
        return [];
      }

      // --- 3. VALIDAZIONE, CALCOLO E FILTRAGGIO ---

      List<Fioraio> listaFiorai = [];

      for (var item in results) {
        try {
          // Estraiamo temporaneamente le coordinate per calcolare la distanza
          final latFioraio = item['geometry']['location']['lat'] as double;
          final lngFioraio = item['geometry']['location']['lng'] as double;

          // Geolocator ha una funzione comodissima che fa la trigonometria per noi
          // Restituisce la distanza in metri, la dividiamo per 1000 per avere i km
          final distanzaMetri = Geolocator.distanceBetween(
            posizioneAttuale.latitude,
            posizioneAttuale.longitude,
            latFioraio,
            lngFioraio,
          );

          // Passiamo il JSON e la distanza alla nostra Entità difensiva
          final fioraioValidato = Fioraio.fromGoogleMapsJson(
            item as Map<String, dynamic>,
            distanzaCalcolata: distanzaMetri / 1000,
          );

          listaFiorai.add(fioraioValidato);
        } catch (e) {
          // PROGRAMMAZIONE DIFENSIVA IN AZIONE:
          // Se un fioraio ha coordinate sballate, la factory lancerà un'eccezione.
          // Noi la catturiamo *dentro* il ciclo for. In questo modo ignoriamo
          // SOLO quel fioraio rotto, salvando tutti gli altri negozi validi!
          debugPrint('Fioraio scartato per dati non validi: $e');
        }
      }

      // 4. Ordiniamo la lista dal più vicino (distanza minore) al più lontano
      listaFiorai.sort((a, b) => a.distanzaKm.compareTo(b.distanzaKm));

      return listaFiorai;

    } catch (e) {
      debugPrint("Errore nel LogisticaFacade: $e");
      rethrow; // Rilanciamo l'errore per far apparire un popup rosso nella UI
    }
  }
}