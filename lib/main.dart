import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. AGGIUNGI QUESTO IMPORT
import 'firebase_options.dart';

import 'views/Auth/login_screen.dart';
import 'views/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. CARICA IL FILE .ENV QUI (Prima di Firebase o altre configurazioni)
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Avvolgiamo l'app in ProviderScope per abilitare Riverpod
  runApp(const ProviderScope(child: FloraLensApp()));
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
          secondary: const Color(0xFF81C784),
          background: const Color(0xFFF3F6F8),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              ),
            );
          }
          if (snapshot.hasData) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}