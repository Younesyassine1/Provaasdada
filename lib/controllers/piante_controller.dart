import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/entities/pianta.dart';

class PianteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<List<Pianta>> miePiante = ValueNotifier<List<Pianta>>([]);

  // --- RIFERIMENTO AL DATABASE PRIVATO ---
  // Ottiene il "cassetto" delle piante dedicato esclusivamente all'utente loggato
  CollectionReference get _pianteCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Errore: Utente non loggato!");
    return _firestore.collection('utenti').doc(uid).collection('mie_piante');
  }

  // --- CRUD FIREBASE ---

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

  // NUOVO: Sostituisce l'insertPianta di SQLite
  Future<void> salvaPianta(Pianta pianta) async {
    try {
      // .doc().set() genera automaticamente un ID alfanumerico univoco stile Firebase
      await _pianteCollection.doc().set(pianta.toFirestore());
      await caricaPiante(); // Aggiorna la UI in tempo reale
    } catch (e) {
      debugPrint("Errore nel salvataggio Cloud: $e");
      rethrow; // Passiamo l'errore alla UI
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
      // In Firebase basta inviare solo il campo che vogliamo aggiornare!
      await _pianteCollection.doc(pianta.id).update({
        'dataUltimaAnnaffiatura': piantaAggiornata.dataUltimaAnnaffiatura?.toIso8601String()
      });
      await caricaPiante();
    } catch (e) {
      debugPrint("Errore nell'aggiornamento Cloud: $e");
    }
  }
}