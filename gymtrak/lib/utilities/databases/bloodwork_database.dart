import 'dart:convert';
import 'package:gymtrak/utilities/bloodwork/dataclasses/bloodwork_result.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BloodWorkDatabaseHelper {
  static const _databaseName = "BloodWorkDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'blood_work_results';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnFolder = 'folder';
  static const columnDate = 'date';
  static const columnParameterValues = 'parameterValues';
  // Add other fields specific to Bloodwork

  // Singleton class setup
  BloodWorkDatabaseHelper._privateConstructor();
  static final BloodWorkDatabaseHelper instance = BloodWorkDatabaseHelper._privateConstructor();

  // Single database reference
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  _initDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnName TEXT NOT NULL,
            $columnFolder TEXT NOT NULL,
            $columnDate TEXT NOT NULL,
            $columnParameterValues TEXT NOT NULL
          )
          ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> insertBloodWorkResult(BloodWorkResult result) async {
    final db = await instance.database;
    var map = result.toMap();

    return await db.insert(table, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateBloodWorkResult(BloodWorkResult result) async {
    final db = await instance.database;
    var map = result.toMap();

    return await db.update(
      table,
      map,
      where: '$columnId = ?',
      whereArgs: [result.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteBloodWorkResult(int id) async {
    final db = await instance.database;

    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<BloodWorkResult>> getAllBloodWorkResults() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return maps.map((map) {
      Map<String, dynamic> tempParameterValues = Map<String, dynamic>.from(json.decode(map[columnParameterValues]));
      Map<String, double> parameterValues = tempParameterValues.map((key, value) => MapEntry(key, value.toDouble()));

      return BloodWorkResult(
        id: map[columnId],
        name: map[columnName],
        folder: map[columnFolder],
        date: DateTime.parse(map[columnDate]),
        parameterValues: parameterValues,
      );
    }).toList();
  }

  Future<bool> doesIdExist(int id) async {
    final db = await instance.database;
    final result = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<void> deleteAllTables() async {
    final db = await instance.database;
    await db.delete(table);
  }
}
