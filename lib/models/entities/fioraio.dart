class Fioraio {
  final String id;
  final String nome;
  final String indirizzo;
  final double latitudine;
  final double longitudine;
  final double distanzaKm;

  // Costruttore privato: come per Pianta, forziamo l'uso della Factory
  Fioraio._({
    required this.id,
    required this.nome,
    required this.indirizzo,
    required this.latitudine,
    required this.longitudine,
    required this.distanzaKm,
  });

  // --- FACTORY DIFENSIVA (Da Google Maps Places API) ---
  // Nota: Il Facade calcolerà la distanza con il GPS e la passerà a questa factory.
  factory Fioraio.fromGoogleMapsJson(Map<String, dynamic> json, {required double distanzaCalcolata}) {

    // 1. Estrazione dati testuali con fallback sicuri
    final nomeEstratto = json['name']?.toString() ?? 'Vivaio Sconosciuto';
    final idEstratto = json['place_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    // 'vicinity' è il campo che Google Maps usa spesso per l'indirizzo breve
    final indirizzoEstratto = json['vicinity']?.toString() ?? 'Indirizzo non disponibile';

    // 2. Estrazione profonda delle coordinate (evitando NullPointerException)
    final location = json['geometry']?['location'] ?? {};
    final double? lat = location['lat'] as double?;
    final double? lng = location['lng'] as double?;

    // --- LOGICA DI BUSINESS: VALIDAZIONE GPS CRITICA ---

    if (lat == null || lng == null) {
      throw const FormatException('Coordinate mancanti nel JSON di Google Maps. Impossibile posizionare il marker.');
    }

    // Le coordinate terrestri hanno limiti matematici ben precisi.
    // Se Google (o un mock di test) ci passa latitudini oltre i 90 gradi, la mappa andrà in crash.
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
      throw const FormatException('Coordinate geografiche matematicamente impossibili.');
    }

    // 3. Creazione sicura dell'oggetto validato
    return Fioraio._(
      id: idEstratto,
      nome: nomeEstratto,
      indirizzo: indirizzoEstratto,
      latitudine: lat,
      longitudine: lng,
      distanzaKm: distanzaCalcolata,
    );
  }

  // --- GETTER PER LA UI ---
  // Questo formattatore crea la stringa esatta che hai inserito nel tuo mockup HTML (es. "1.4 km")
  // sollevando la View dal dover fare arrotondamenti matematici.
  String get distanzaFormattata => '${distanzaKm.toStringAsFixed(1)} km';
}