import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // IMPORT FONDAMENTALE
import 'firebase_options.dart'; // IL FILE GENERATO PRIMA
import 'views/Auth/login_screen.dart';

// ATTENZIONE: deve esserci "async" qui
void main() async {
  // 1. Assicura che Flutter sia inizializzato prima di chiamare codice nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. "Accende" Firebase usando le chiavi del tuo progetto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FloraLensApp());
}

class FloraLensApp extends StatelessWidget {
  const FloraLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloraLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF4CAF50),
        ),
        scaffoldBackgroundColor: const Color(0xFFE0E5EC),
      ),
      home: const LoginScreen(),
    );
  }
}