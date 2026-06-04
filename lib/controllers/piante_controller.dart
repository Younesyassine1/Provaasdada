import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/entities/pianta.dart';

class PianteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<List<Pianta>> miePiante = ValueNotifier<List<Pianta>>([]);

  CollectionReference get _pianteCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Errore: Utente non loggato!");
    return _firestore.collection('utenti').doc(uid).collection('mie_piante');
  }

  Future<void> caricaPiante() async {
    try {
      final snapshot = await _pianteCollection.get();
      final lista = snapshot.docs.map((doc) {
        return Pianta.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      miePiante.value = lista;
    } catch (e) {
      debugPrint("Errore nel caricamento dal Cloud: $e");
    }
  }

  Future<void> salvaPianta(Pianta pianta) async {
    try {
      final snapshotEsistente = await _pianteCollection
          .where('specie', isEqualTo: pianta.specie)
          .get();

      if (snapshotEsistente.docs.isNotEmpty) {
        throw Exception("Hai giÃ  questa pianta nella tua serra!");
      }

      await _pianteCollection.doc().set(pianta.toFirestore());
      await caricaPiante();
    } catch (e) {
      debugPrint("Errore nel salvataggio Cloud: $e");
      rethrow;
    }
  }

  Future<void> cambiaPosizionePianta(Pianta pianta, bool isEsterno) async {
    try {
      await _pianteCollection.doc(pianta.id).update({
        'isDaEsterno': isEsterno
      });
      await caricaPiante();
    } catch (e) {
      debugPrint("Errore cambio posizione: $e");
    }
  }

  Future<void> eliminaPianta(String idPianta) async {
    try {
      await _pianteCollection.doc(idPianta).delete();
      await caricaPiante();
    } catch (e) {
      debugPrint("Errore nell'eliminazione Cloud: $e");
    }
  }

  Future<void> innaffiaPianta(Pianta pianta) async {
    try {
      final piantaAggiornata = pianta.copiaCon(nuovaDataAnnaffiatura: DateTime.now());
      await _pianteCollection.doc(pianta.id).update({
        'dataUltimaAnnaffiatura': piantaAggiornata.dataUltimaAnnaffiatura?.toIso8601String()
      });
      await caricaPiante();
    } catch (e) {
      debugPrint("Errore nell'aggiornamento Cloud: $e");
    }
  }

  // NUOVO: Scrittura sul Cloud per la pulizia delle foglie
  Future<void> pulisciPianta(Pianta pianta) async {
    try {
      final piantaAggiornata = pianta.copiaCon(nuovaDataPulizia: DateTime.now());
      await _pianteCollection.doc(pianta.id).update({
        'dataUltimaPulizia': piantaAggiornata.dataUltimaPulizia?.toIso8601String()
      });
      await caricaPiante(); // Ricarichiamo la UI dopo aver salvato
    } catch (e) {
      debugPrint("Errore nell'aggiornamento Pulizia Cloud: $e");
    }
  }
}