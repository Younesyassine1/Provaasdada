import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  // Istanza principale di Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variabile reattiva per mostrare eventuali caricamenti nella UI
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  // --- REGISTRAZIONE ---
  Future<bool> registra({
    required String nome,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // 1. Crea l'utente sui server di Google
      UserCredential credenziali = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Salva il Nome dell'utente direttamente nel suo profilo Auth
      await credenziali.user?.updateDisplayName(nome);

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Errore Registrazione Firebase: ${e.code}");
      return false;
    } catch (e) {
      debugPrint("Errore generico: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN ---
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // 1. Tenta il login sui server di Google
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Errore Login Firebase: ${e.code}");
      return false;
    } catch (e) {
      debugPrint("Errore generico: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT E UTILITÀ ---

  /// Disconnette l'utente corrente
  Future<void> esci() async {
    await _auth.signOut();
  }

  /// Restituisce l'utente attualmente loggato (con il suo ID, Nome, Email)
  User? get utenteCorrente => _auth.currentUser;

  // --- PRESENTATION LOGIC ---

  /// Restituisce solo il primo nome dell'utente loggato, gestendo il fallback della lingua.
  String ottieniNomeFormattato(bool isItaliano) {
    // 1. Prende il nome dal token, se nullo usa il fallback
    final String nomeCompleto = _auth.currentUser?.displayName ?? (isItaliano ? 'Utente' : 'User');

    // 2. Esegue la logica di business (estrarre solo il primo nome)
    return nomeCompleto.split(' ').first;
  }
}