import 'package:gymtrak/utilities/bloodwork/bloodwork_parameter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GeneralDatabase {
  static const _databaseName = "GeneralDatabase.db";
  static const _databaseVersion = 1;
  static const tableBloodworkParameters = 'blood_work_parameters';
  static const tableBloodworkFolders = 'blood_work_folders';

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

  // Folders
  Future<int> createFolder(String folderName) async {
    final db = await instance.database;
    final id = await db.insert(tableBloodworkFolders, {'name': folderName});
    return id;
  }

  Future<int> updateFolder(int id, String folderName) async {
    final db = await instance.database;
    return db.update(
      tableBloodworkFolders,
      {'name': folderName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<int, String>> readAllFolders() async {
    final db = await instance.database;
    const orderBy = 'id ASC';
    final result = await db.query(tableBloodworkFolders, orderBy: orderBy);

    return {for (var item in result) item['id'] as int: item['name'] as String};
  }

  Future<int> deleteFolder(int id) async {
    final db = await instance.database;
    return db.delete(
      tableBloodworkFolders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
