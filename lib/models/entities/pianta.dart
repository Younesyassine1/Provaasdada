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

  // =========================================================
  // 1. LOGICA DI BUSINESS (TEMPI REALI DI ATTESA)
  // =========================================================

  /// Trasforma il fabbisogno d'acqua a 5 livelli in giorni di attesa reali
  int get giorniAttesaAcqua {
    switch (fabbisognoAcqua) {
      case 'Molto alto': return 1;   // Va annaffiata ogni giorno
      case 'Alto': return 3;         // Ogni 3 giorni
      case 'Moderato': return 5;     // Ogni 5 giorni
      case 'Basso': return 9;        // Ogni 9 giorni
      case 'Molto basso': return 15; // Ogni 15 giorni
      default: return 5;
    }
  }

  /// Stabilisce se la pianta ha attualmente bisogno di acqua
  bool get puoAnnaffiare {
    if (dataUltimaAnnaffiatura == null) return true; // Mai annaffiata? Allora sì!

    // Calcoliamo l'esatto momento in cui si sbloccherà
    final prossimaAnnaffiatura = dataUltimaAnnaffiatura!.add(Duration(days: giorniAttesaAcqua));

    // È sbloccata solo se il momento attuale ha superato la data di sblocco
    return DateTime.now().isAfter(prossimaAnnaffiatura);
  }

  /// Stabilisce se le foglie hanno bisogno di essere pulite (Fisso: 14 giorni)
  bool get puoPulire {
    if (dataUltimaPulizia == null) return true;

    final prossimaPulizia = dataUltimaPulizia!.add(const Duration(days: 14));
    return DateTime.now().isAfter(prossimaPulizia);
  }


  // =========================================================
  // 2. FORMATTAZIONE DEL TEMPO MANCANTE (FORMATO DINAMICO)
  // =========================================================

  String tempoMancanteAcqua(bool isIt) {
    if (dataUltimaAnnaffiatura == null) return "";

    final prossimaMossa = dataUltimaAnnaffiatura!.add(Duration(days: giorniAttesaAcqua));
    final diff = prossimaMossa.difference(DateTime.now());

    if (diff.isNegative) return ""; // Già sbloccato
    return _formattaDurata(diff, isIt);
  }

  String tempoMancantePulizia(bool isIt) {
    if (dataUltimaPulizia == null) return "";

    final prossimaMossa = dataUltimaPulizia!.add(const Duration(days: 14));
    final diff = prossimaMossa.difference(DateTime.now());

    if (diff.isNegative) return "";
    return _formattaDurata(diff, isIt);
  }

  /// Converte la differenza di tempo nel formato richiesto (Giorni -> HH:MM -> MM:SS)
  String _formattaDurata(Duration diff, bool isIt) {
    if (diff.inDays >= 1) {
      // 1. MANCA PIÙ DI UN GIORNO: Mostra solo i giorni
      if (diff.inDays == 1) return isIt ? '1 giorno' : '1 day';
      return '${diff.inDays} ${isIt ? "giorni" : "days"}';

    } else if (diff.inHours >= 1) {
      // 2. MANCA MENO DI UN GIORNO MA PIÙ DI UN'ORA: Formato HH:MM
      // padLeft(2, '0') serve per scrivere "05" invece di "5"
      final ore = diff.inHours.toString().padLeft(2, '0');
      final minuti = (diff.inMinutes % 60).toString().padLeft(2, '0');
      return '$ore:$minuti h';

    } else {
      // 3. MANCA MENO DI UN'ORA: Formato MM:SS
      final minuti = diff.inMinutes.toString().padLeft(2, '0');
      final secondi = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return '$minuti:$secondi min';
    }
  }


  // =========================================================
  // 3. FACTORIES E METODI ESISTENTI
  // =========================================================

  factory Pianta.fromTrefleJson(Map<String, dynamic> json, {required bool isDaEsterno}) {
    final data = json['data'] ?? {};
    final specieEstratta = data['scientific_name']?.toString();
    if (specieEstratta == null || specieEstratta.isEmpty) {
      throw const FormatException('Specie non identificata nel JSON di Trefle');
    }
    final growth = data['growth'] ?? {};

    String mappaValore10(int? valore) {
      if (valore == null) return 'Moderato';
      if (valore <= 2) return 'Molto basso';
      if (valore <= 4) return 'Basso';
      if (valore == 5) return 'Moderato';
      if (valore <= 7) return 'Alto';
      return 'Molto alto';
    }

    return Pianta._(
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

  factory Pianta.fromFirestore(Map<String, dynamic> map, String documentId) {
    return Pianta._(
      id: documentId,
      nomeComune: map['nomeComune'] ?? 'Sconosciuto',
      specie: map['specie'] ?? 'Sconosciuta',
      fabbisognoAcqua: map['fabbisognoAcqua'] ?? 'Moderato',
      fabbisognoLuce: map['fabbisognoLuce'] ?? 'Moderato',
      fabbisognoUmidita: map['fabbisognoUmidita'] ?? 'Moderato',
      isDaEsterno: map['isDaEsterno'] ?? false,
      dataUltimaAnnaffiatura: map['dataUltimaAnnaffiatura'] != null
          ? DateTime.parse(map['dataUltimaAnnaffiatura'] as String)
          : null,
      dataUltimaPulizia: map['dataUltimaPulizia'] != null
          ? DateTime.parse(map['dataUltimaPulizia'] as String)
          : null,
      immagineUrl: map['immagineUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nomeComune': nomeComune,
      'specie': specie,
      'fabbisognoAcqua': fabbisognoAcqua,
      'fabbisognoLuce': fabbisognoLuce,
      'fabbisognoUmidita': fabbisognoUmidita,
      'isDaEsterno': isDaEsterno,
      'dataUltimaAnnaffiatura': dataUltimaAnnaffiatura?.toIso8601String(),
      'dataUltimaPulizia': dataUltimaPulizia?.toIso8601String(),
      'immagineUrl': immagineUrl,
    };
  }

  Pianta copiaCon({
    DateTime? nuovaDataAnnaffiatura,
    DateTime? nuovaDataPulizia,
    bool? isDaEsterno,
  }) {
    return Pianta._(
      id: id,
      nomeComune: nomeComune,
      specie: specie,
      fabbisognoAcqua: fabbisognoAcqua,
      fabbisognoLuce: fabbisognoLuce,
      fabbisognoUmidita: fabbisognoUmidita,
      isDaEsterno: isDaEsterno ?? this.isDaEsterno,
      dataUltimaAnnaffiatura: nuovaDataAnnaffiatura ?? dataUltimaAnnaffiatura,
      dataUltimaPulizia: nuovaDataPulizia ?? dataUltimaPulizia,
      immagineUrl: immagineUrl,
    );
  }
}