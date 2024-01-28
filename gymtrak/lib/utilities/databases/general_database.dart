import 'package:gymtrak/utilities/bloodwork/dataclasses/bloodwork_parameter.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GeneralDatabase {
  static const _databaseName = "GeneralDatabase.db";
  static const _databaseVersion = 1;
  static const tableBloodworkParameters = 'blood_work_parameters';
  static const tableBloodworkFolders = 'blood_work_folders';
  static const tableMedicationFolders = 'medication_folders';

  static final GeneralDatabase instance = GeneralDatabase._init();
  static Database? _database;

  GeneralDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(path, version: _databaseVersion, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE $tableBloodworkParameters (
      id $idType, 
      name $textType,
      fullName $textType,
      category $textType,
      upperLimit $doubleType,
      lowerLimit $doubleType,
      unit $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableBloodworkFolders (
      id $idType,
      name $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableMedicationFolders (
      id $idType,
      name $textType
    )
    ''');
  }

  Future deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    await deleteDatabase(path);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // BloodWorkParameters
  Future<int> createBloodWorkParameter(BloodWorkParameter param) async {
    final db = await instance.database;
    final id = await db.insert(tableBloodworkParameters, param.toMap());
    return id;
  }

  Future<Map<int, BloodWorkParameter>> readAllBloodWorkParameters() async {
    final db = await instance.database;
    const orderBy = 'id ASC';
    final result = await db.query(tableBloodworkParameters, orderBy: orderBy);

    return {for (var item in result) item['id'] as int: BloodWorkParameter.fromMap(item)};
  }

  Future<int> updateBloodWorkParameter(BloodWorkParameter param) async {
    final db = await instance.database;

    return db.update(
      tableBloodworkParameters,
      param.toMap(),
      where: 'id = ?',
      whereArgs: [param.id],
    );
  }

  Future<int> deleteBloodWorkParameter(int id) async {
    final db = await instance.database;
    return db.delete(
      tableBloodworkParameters,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MedicationComponents
  Future<int> createMedicationComponent(MedicationComponent component) async {
    final db = await instance.database;
    final id = await db.insert(tableBloodworkParameters, component.toMap());
    return id;
  }

  Future<Map<int, MedicationComponent>> readAllMedicationComponents() async {
    final db = await instance.database;
    const orderBy = 'id ASC';
    final result = await db.query(tableBloodworkParameters, orderBy: orderBy);

    return {for (var item in result) item['id'] as int: MedicationComponent.fromMap(item)};
  }

  Future<int> updateMedicationComponent(MedicationComponent component) async {
    final db = await instance.database;

    return db.update(
      tableBloodworkParameters,
      component.toMap(),
      where: 'id = ?',
      whereArgs: [component.id],
    );
  }

  Future<int> deleteMedicationComponent(int id) async {
    final db = await instance.database;
    return db.delete(
      tableBloodworkParameters,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Folders
  Future<int> createFolder(String folderName, [String? table]) async {
    final db = await instance.database;
    if (table == null) {
      return await db.insert(tableBloodworkFolders, {'name': folderName});
    } else {
      return await db.insert(tableMedicationFolders, {'name': folderName});
    }
  }

  Future<int> updateFolder(int id, String folderName, [String? table]) async {
    final db = await instance.database;
    if (table == null) {
      return db.update(
        tableBloodworkFolders,
        {'name': folderName},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      return db.update(
        tableMedicationFolders,
        {'name': folderName},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<Map<int, String>> readAllFolders([String? table]) async {
    final db = await instance.database;
    if (table == null) {
      const orderBy = 'id ASC';
      final result = await db.query(tableBloodworkFolders, orderBy: orderBy);

      return {for (var item in result) item['id'] as int: item['name'] as String};
    } else {
      const orderBy = 'id ASC';
      final result = await db.query(tableMedicationFolders, orderBy: orderBy);

      return {for (var item in result) item['id'] as int: item['name'] as String};
    }
  }

  Future<int> deleteFolder(int id, [String? table]) async {
    final db = await instance.database;
    if (table == null) {
      return db.delete(
        tableBloodworkFolders,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      return db.delete(
        tableMedicationFolders,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteAllTables() async {
    final db = await instance.database;
    await db.delete(tableBloodworkParameters);
    await db.delete(tableBloodworkFolders);
    await db.delete(tableMedicationFolders);
  }
}
