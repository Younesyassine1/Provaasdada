import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Serve per leggere la cache di Firebase
import 'firebase_options.dart';

import 'views/Auth/login_screen.dart';
import 'views/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

      // IL NOSTRO CASELLO INTELLIGENTE
      home: StreamBuilder<User?>(
        // Ascolta in tempo reale la "cache" di Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // 1. Mentre controlla la memoria del telefono, mostra un caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFE0E5EC),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              ),
            );
          }

          // 2. Se trova il Token in memoria (Utente loggato in precedenza)
          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          // 3. Se la cache è vuota o l'utente ha fatto il logout
          return const LoginScreen();
        },
      ),
    );
  }
}
