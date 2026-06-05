import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/piante_controller.dart';
import '../../controllers/fiorai_controller.dart';
import '../../controllers/meteo_controller.dart';
import '../../controllers/botanic_controller.dart';

// Esponiamo i controller esistenti tramite Riverpod come Singleton globali sicuri
final authProvider = Provider<AuthController>((ref) => AuthController());
final linguaProvider = Provider<LinguaController>((ref) => LinguaController());
final pianteProvider = Provider<PianteController>((ref) => PianteController());
final fioraiProvider = Provider<FioraiController>((ref) => FioraiController());
final meteoProvider = Provider<MeteoController>((ref) => MeteoController());
final botanicaProvider = Provider<BotanicaController>((ref) => BotanicaController());