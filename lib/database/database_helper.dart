import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/app_storage.dart';

final databaseHelper = DatabaseHelper.instance;

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      final databaseFactory = databaseFactoryFfi;
      final db = await databaseFactory.openDatabase(appStorage.databasePath, options: OpenDatabaseOptions(onCreate: _onCreate, version: 1));
      return db;
    }
    return await openDatabase(
      appStorage.databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> notifySelectedUserChanged() async {
    await _database?.close();
    _database = await _openDatabase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
                     CREATE TABLE IF NOT EXISTS files (
                        id TEXT PRIMARY KEY NOT NULL,
                        name TEXT NOT NULL,
                        parent_id TEXT NOT NULL,
                        type TEXT NOT NULL,
                        created INTEGER NOT NULL,
                        modified INTEGER NOT NULL,
                        uploaded INTEGER NOT NULL,
                        deleted INTEGER,
                        sha256 TEXT NOT NULL,
                        size INTEGER NOT NULL
                      );
                        """);
    await db.execute("""
                     CREATE TABLE IF NOT EXISTS themes (
                        id TEXT PRIMARY KEY NOT NULL,
                        title TEXT NOT NULL,
                        created INTEGER NOT NULL,
                        modified INTEGER NOT NULL,
            
                        background_light INTEGER NOT NULL,
                        text_light INTEGER NOT NULL,
                        accent_light INTEGER NOT NULL,
                        card_light INTEGER NOT NULL,
                        folder_front_light INTEGER NOT NULL,
                        folder_back_light INTEGER NOT NULL,
            
                        background_dark INTEGER NOT NULL,
                        text_dark INTEGER NOT NULL,
                        accent_dark INTEGER NOT NULL,
                        card_dark INTEGER NOT NULL,
                        folder_front_dark INTEGER NOT NULL,
                        folder_back_dark INTEGER NOT NULL
                      );
                        """);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
