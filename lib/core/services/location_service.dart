import 'package:geolocator/geolocator.dart';

class LocationService {

  /// Gestisce i permessi e restituisce la posizione attuale dell'utente.
  /// Lancia un'eccezione se i servizi sono spenti o i permessi negati.
  Future<Position> ottieniPosizioneAttuale({
    LocationAccuracy precisione = LocationAccuracy.medium,
  }) async {

    // 1. Controlla se il GPS del dispositivo è acceso
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('I servizi di localizzazione sono spenti. Accendi il GPS.');
    }

    // 2. Controlla i permessi dell'App
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permessi di localizzazione negati dall utente.');
        }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception('Permessi negati permanentemente. Cambiali dalle impostazioni del telefono.');
        }

        // 3. Tutto ok, restituisce le coordinate
        return await Geolocator.getCurrentPosition(desiredAccuracy: precisione);
      }
}
