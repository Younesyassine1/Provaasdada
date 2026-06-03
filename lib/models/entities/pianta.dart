class Pianta {
  final String id;
  final String nomeComune;
  final String specie;
  final String fabbisognoAcqua;
  final String fabbisognoLuce;
  final String fabbisognoUmidita;
  final bool isDaEsterno;
  final DateTime? dataUltimaAnnaffiatura;
  final DateTime? dataUltimaPulizia;
  final String? immagineUrl;

  Pianta._({
    required this.id,
    required this.nomeComune,
    required this.specie,
    required this.fabbisognoAcqua,
    required this.fabbisognoLuce,
    required this.fabbisognoUmidita,
    required this.isDaEsterno,
    this.dataUltimaAnnaffiatura,
    this.dataUltimaPulizia,
    this.immagineUrl,
  });

  // --- 1. FACTORY DA TREFLE API ---
  factory Pianta.fromTrefleJson(Map<String, dynamic> json, {required bool isDaEsterno}) {
    final data = json['data'] ?? {};

    final specieEstratta = data['scientific_name']?.toString();
    if (specieEstratta == null || specieEstratta.isEmpty) {
      throw const FormatException('Specie non identificata nel JSON di Trefle');
    }

    final growth = data['growth'] ?? {};

    String mappaValore10(int? valore) {
      if (valore == null) return 'Moderato';
      if (valore <= 3) return 'Basso';
      if (valore <= 7) return 'Moderato';
      return 'Alto';
    }

    return Pianta._(
      // Usiamo il nome specie ripulito come ID temporaneo per la UI
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nomeComune: data['common_name']?.toString() ?? specieEstratta,
      specie: specieEstratta,
      fabbisognoAcqua: mappaValore10(growth['atmospheric_humidity'] as int?),
      fabbisognoUmidita: mappaValore10(growth['atmospheric_humidity'] as int?),
      fabbisognoLuce: mappaValore10(growth['light'] as int?),
      isDaEsterno: isDaEsterno,
      dataUltimaAnnaffiatura: null,
      dataUltimaPulizia: null,
      immagineUrl: data['image_url']?.toString(),
    );
  }

  // --- 2. FACTORY CLOUD (Da Firebase Firestore) ---
  factory Pianta.fromFirestore(Map<String, dynamic> map, String documentId) {
    return Pianta._(
      id: documentId, // L'ID ora Ã¨ quello del documento generato da Firebase
      nomeComune: map['nomeComune'] ?? 'Sconosciuto',
      specie: map['specie'] ?? 'Sconosciuta',
      fabbisognoAcqua: map['fabbisognoAcqua'] ?? '',
      fabbisognoLuce: map['fabbisognoLuce'] ?? '',
      fabbisognoUmidita: map['fabbisognoUmidita'] ?? '',
      isDaEsterno: map['isDaEsterno'] ?? false, // Firebase usa i bool nativi!
      dataUltimaAnnaffiatura: map['dataUltimaAnnaffiatura'] != null
          ? DateTime.parse(map['dataUltimaAnnaffiatura'] as String)
          : null,
      dataUltimaPulizia: map['dataUltimaPulizia'] != null
          ? DateTime.parse(map['dataUltimaPulizia'] as String)
          : null,
      immagineUrl: map['immagineUrl'] as String?,
    );
  }

  // --- 3. ESPORTAZIONE (Verso Firebase Firestore) ---
  Map<String, dynamic> toFirestore() {
    return {
      'nomeComune': nomeComune,
      'specie': specie,
      'fabbisognoAcqua': fabbisognoAcqua,
      'fabbisognoLuce': fabbisognoLuce,
      'fabbisognoUmidita': fabbisognoUmidita,
      'isDaEsterno': isDaEsterno, // Salviamo direttamente come true/false
      'dataUltimaAnnaffiatura': dataUltimaAnnaffiatura?.toIso8601String(),
      'dataUltimaPulizia': dataUltimaPulizia?.toIso8601String(),
      'immagineUrl': immagineUrl,
    };
  }

  Pianta copiaCon({DateTime? nuovaDataAnnaffiatura, DateTime? nuovaDataPulizia}) {
    return Pianta._(
      id: id,
      nomeComune: nomeComune,
      specie: specie,
      fabbisognoAcqua: fabbisognoAcqua,
      fabbisognoLuce: fabbisognoLuce,
      fabbisognoUmidita: fabbisognoUmidita,
      isDaEsterno: isDaEsterno,
      dataUltimaAnnaffiatura: nuovaDataAnnaffiatura ?? dataUltimaAnnaffiatura,
      dataUltimaPulizia: nuovaDataPulizia ?? dataUltimaPulizia,
      immagineUrl: immagineUrl,
    );
  }
}