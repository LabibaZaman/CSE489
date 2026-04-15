import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/landmark.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize for Windows/Linux if needed
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'landmarks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE landmarks(
            id TEXT PRIMARY KEY,
            title TEXT,
            lat REAL,
            lon REAL,
            image TEXT,
            score REAL,
            visit_count INTEGER,
            avg_distance REAL,
            is_deleted INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE visits(
            id TEXT PRIMARY KEY,
            landmark_id TEXT,
            landmark_name TEXT,
            visit_time TEXT,
            distance REAL,
            is_synced INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_visits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            landmark_id TEXT,
            user_lat REAL,
            user_lon REAL,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertLandmarks(List<Landmark> landmarks) async {
    final db = await database;
    Batch batch = db.batch();
    for (var landmark in landmarks) {
      batch.insert('landmarks', landmark.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Landmark>> getLandmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('landmarks', where: 'is_deleted = 0');
    return List.generate(maps.length, (i) => Landmark.fromJson(maps[i]));
  }

  Future<void> insertVisit(Visit visit) async {
    final db = await database;
    await db.insert('visits', visit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Visit>> getVisits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('visits', orderBy: 'visit_time DESC');
    return List.generate(maps.length, (i) => Visit.fromMap(maps[i]));
  }

  Future<void> addPendingVisit(String landmarkId, double lat, double lon) async {
    final db = await database;
    await db.insert('pending_visits', {
      'landmark_id': landmarkId,
      'user_lat': lat,
      'user_lon': lon,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingVisits() async {
    final db = await database;
    return await db.query('pending_visits');
  }

  Future<void> deletePendingVisit(int id) async {
    final db = await database;
    await db.delete('pending_visits', where: 'id = ?', whereArgs: [id]);
  }
}
