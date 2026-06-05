import 'package:flutter_dotenv/flutter_dotenv.dart';

// dotenv.env restituisce una mappa. Usiamo ?? '' come fallback 
// nel caso in cui il file .env non venga trovato o letto correttamente.
String get APIKEYPLANT => dotenv.env['PLANTNET_API_KEY'] ?? '';
String get APIKEYTREFLE => dotenv.env['TREFLE_API_KEY'] ?? '';