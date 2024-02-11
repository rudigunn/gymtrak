import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class NotificationDatabaseHelper {
  static const _databaseName = "NotificationDatabase.db";
  static const _databaseVersion = 1;
  static const tableNotificationEntries = 'notification_entries';

  // Singleton class setup
  NotificationDatabaseHelper._privateConstructor();
  static final NotificationDatabaseHelper instance =
      NotificationDatabaseHelper._privateConstructor();

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
    var dbFactory = databaseFactoryIo;
    return await dbFactory.openDatabase(path, version: _databaseVersion);
  }

  // Delete the database
  _deleteDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    var dbFactory = databaseFactoryIo;
    _database = null;
    return await dbFactory.deleteDatabase(path);
  }

  Future<void> deleteDatabase() async {
    await _deleteDatabase();
  }

  // CRUD operations
}
