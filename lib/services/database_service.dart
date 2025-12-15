import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/offline_movie.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'offline_movies.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_movies (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        titleEnglish TEXT,
        filePath TEXT NOT NULL,
        coverPath TEXT NOT NULL,
        quality TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        downloadDate TEXT NOT NULL,
        isDownloaded INTEGER NOT NULL,
        rating REAL,
        runtime INTEGER,
        genres TEXT,
        summary TEXT,
        language TEXT,
        backgroundImage TEXT
      )
    ''');
  }

  // Insert offline movie
  Future<int> insertOfflineMovie(OfflineMovie movie) async {
    final db = await database;
    return await db.insert(
      'offline_movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all offline movies
  Future<List<OfflineMovie>> getOfflineMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('offline_movies');
    return List.generate(maps.length, (i) {
      return OfflineMovie.fromMap(maps[i]);
    });
  }

  // Get offline movie by ID
  Future<OfflineMovie?> getOfflineMovie(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'offline_movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return OfflineMovie.fromMap(maps.first);
    }
    return null;
  }

  // Update download status
  Future<int> updateDownloadStatus(int id, bool isDownloaded) async {
    final db = await database;
    return await db.update(
      'offline_movies',
      {'isDownloaded': isDownloaded ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete offline movie
  Future<int> deleteOfflineMovie(int id) async {
    final db = await database;
    return await db.delete(
      'offline_movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if movie exists offline
  Future<bool> isMovieOffline(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'offline_movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}
