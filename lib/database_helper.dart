import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final _databaseName = "aquariumSettings.db";
  static final _databaseVersion = 1;

  static final table = 'settings';

  static final columnId = '_id';
  static final columnFishCount = 'fishCount';
  static final columnSpeed = 'speed';
  static final columnColor = 'color';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnFishCount INTEGER NOT NULL,
        $columnSpeed REAL NOT NULL,
        $columnColor TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = await db!.insert(table, row);
    print("Inserted row id: $id with data: $row");
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    return await db!.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await instance.database;
    if (db == null) {
      throw Exception("Database is not initialized");
    }
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
}
