import 'package:geolocator/geolocator.dart';

class Fioraio {
  final String id;
  final String nome;
  final double latitudine;
  final double longitudine;
  final double distanzaKm;

  Fioraio._({
    required this.id,
    required this.nome,
    required this.latitudine,
    required this.longitudine,
    required this.distanzaKm,
  });

  // FACTORY DA OVERPASS API
  factory Fioraio.fromOverpassJson(Map<String, dynamic> json, {required Position posizioneUtente}) {
    final tags = json['tags'] ?? {};

    // 1. Estrazione Nome e ID
    final nomeEstratto = tags['name']?.toString() ?? 'Fioraio Sconosciuto';
    final idEstratto = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

    // L'indirizzo è stato rimosso per un design più pulito.

    // 2. Estrazione Coordinate
    final double? lat = json['type'] == 'node' ? json['lat'] : json['center']?['lat'];
    final double? lon = json['type'] == 'node' ? json['lon'] : json['center']?['lon'];

    if (lat == null || lon == null) {
      throw const FormatException('Coordinate mancanti nel JSON di Overpass.');
    }

    // 3. Calcolo della distanza in chilometri
    final distanzaMetri = Geolocator.distanceBetween(
      posizioneUtente.latitude,
      posizioneUtente.longitude,
      lat,
      lon,
    );

    return Fioraio._(
      id: idEstratto,
      nome: nomeEstratto,
      latitudine: lat,
      longitudine: lon,
      distanzaKm: distanzaMetri / 1000,
    );
  }

  // GETTER PER LA UI
  String get distanzaFormattata => '${distanzaKm.toStringAsFixed(1)} km';
}