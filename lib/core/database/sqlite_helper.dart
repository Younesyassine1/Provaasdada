import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/entities/pianta.dart';

class SqliteHelper {
  // --- PATTERN SINGLETON ---
  static final SqliteHelper _instance = SqliteHelper._internal();
  factory SqliteHelper() => _instance;
  SqliteHelper._internal();

  static Database? _database;

  // Getter per recuperare il database: se non esiste, lo inizializza.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- INIZIALIZZAZIONE ---
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'floralens.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // --- CREAZIONE TABELLE UNIFICATA ---
  // Viene chiamato automaticamente SOLO la prima volta che si crea il database
  Future<void> _onCreate(Database db, int version) async {
    // 1. Creazione Tabella Piante AGGIORNATA
    await db.execute('''
      CREATE TABLE piante(
        id TEXT PRIMARY KEY,
        nomeComune TEXT,
        specie TEXT,
        fabbisognoAcqua TEXT,
        fabbisognoLuce TEXT,
        fabbisognoUmidita TEXT,
        isDaEsterno INTEGER,
        dataUltimaAnnaffiatura TEXT,
        dataUltimaPulizia TEXT,
        immagineUrl TEXT -- NUOVA COLONNA PER LA FOTO 
      )
    ''');

    // 2. Creazione Tabella Utenti (Auth)
    await db.execute('''
      CREATE TABLE utenti(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // ==========================================
  // --- CRUD PIANTE (La tua serra virtuale) ---
  // ==========================================

  Future<void> insertPianta(Pianta pianta) async {
    final db = await database;
    await db.insert(
      'piante',
      pianta.toLocalDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pianta>> getTutteLePiante() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('piante');

    return List.generate(maps.length, (i) {
      return Pianta.fromLocalDb(maps[i]);
    });
  }

  Future<void> updatePianta(Pianta pianta) async {
    final db = await database;
    await db.update(
      'piante',
      pianta.toLocalDb(),
      where: 'id = ?',
      whereArgs: [pianta.id],
    );
  }

  Future<void> deletePianta(String id) async {
    final db = await database;
    await db.delete(
      'piante',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // --- LOGICA UTENTI E AUTENTICAZIONE ---
  // ==========================================

  /// Registra un nuovo utente. Ritorna 'true' se ha successo, 'false' se l'email esiste già.
  Future<bool> registraUtente(String nome, String email, String password) async {
    final db = await database;
    try {
      await db.insert('utenti', {
        'nome': nome,
        'email': email.toLowerCase().trim(),
        'password': password,
      });
      return true;
    } catch (e) {
      // Se l'inserimento fallisce (es. email duplicata a causa dell'UNIQUE), restituiamo false
      return false;
    }
  }

  /// Verifica se email e password combaciano. Ritorna 'true' se il login è corretto.
  Future<bool> verificaLogin(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utenti',
      where: 'email = ? AND password = ?',
      whereArgs: [email.toLowerCase().trim(), password],
    );

    // Se la query trova una riga, le credenziali sono esatte
    return maps.isNotEmpty;
  }
}