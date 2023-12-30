import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/medication/medication_entry.dart';
import 'package:gymtrak/utilities/medication/medication_plan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MedicationDatabaseHelper {
  static const _databaseName = "MedicationDatabase.db";
  static const _databaseVersion = 1;
  static const tableMedicationEntries = 'medication_entries';
  static const tableMedicationPlans = 'medication_plans';

  static const columnId = 'id';
  static const columnNotes = 'notes';
  static const columnName = 'name';
  static const columnFolder = 'folder';
  static const columnDosage = 'dosage';
  static const columnActive = 'active';
  static const columnDate = 'date';
  static const columnDescription = 'description';
  static const columnComponent = 'medicationComponent';
  static const columnMedicationComponentPlanMap = 'medication_component_plan_map';

  // Singleton class setup
  MedicationDatabaseHelper._privateConstructor();
  static final MedicationDatabaseHelper instance = MedicationDatabaseHelper._privateConstructor();

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

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableMedicationPlans(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnName TEXT NOT NULL,
            $columnFolder TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnActive INT NOT NULL,
            $columnMedicationComponentPlanMap TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableMedicationEntries(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnNotes TEXT NOT NULL,
            $columnDosage REAL NOT NULL,
            $columnDate TEXT NOT NULL,
            $columnComponent TEXT NOT NULL
          )
          ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> insertMedicationEntry(MedicationEntry medicationEntry) async {
    var dbClient = await database;
    var result = await dbClient.insert(tableMedicationEntries, medicationEntry.toMap());
    return result;
  }

  Future<List<MedicationEntry>> getMedicationEntries() async {
    var dbClient = await database;
    List<Map> maps = await dbClient.query(tableMedicationEntries, columns: [
      columnId,
      columnNotes,
      columnDosage,
      columnDate,
      columnComponent,
    ]);
    List<MedicationEntry> medicationEntries = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        medicationEntries.add(MedicationEntry.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return medicationEntries;
  }

  // Insert a new MedicationPlan
  Future<int> insertMedicationPlan(MedicationPlan medicationPlan) async {
    Database db = await database;
    debugPrint('');
    debugPrint(medicationPlan.toMap().toString());
    debugPrint('');
    return await db.insert(tableMedicationPlans, medicationPlan.toMap());
  }

  // Update an existing MedicationPlan
  Future<int> updateMedicationPlan(MedicationPlan medicationPlan) async {
    Database db = await database;
    return await db
        .update(tableMedicationPlans, medicationPlan.toMap(), where: '$columnId = ?', whereArgs: [medicationPlan.id]);
  }

  // Delete a MedicationPlan
  Future<int> deleteMedicationPlan(int id) async {
    Database db = await database;
    return await db.delete(tableMedicationPlans, where: '$columnId = ?', whereArgs: [id]);
  }

  // Retrieve all MedicationPlans
  Future<List<MedicationPlan>> getAllMedicationPlans() async {
    Database db = await database;
    List<Map> maps = await db.query(tableMedicationPlans);
    debugPrint(maps.toString());
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) => MedicationPlan.fromMap(maps[i] as Map<String, dynamic>));
  }
}
