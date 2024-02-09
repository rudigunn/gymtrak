import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_plan.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MedicationDatabaseHelper {
  static const _databaseName = "MedicationDatabase.db";
  static const _databaseVersion = 1;
  static const tableMedicationEntries = 'medication_entries';
  static const tableMedicationPlans = 'medication_plans';
  static const tableMedicationComponents = 'medication_components';
  static const tableNotificationIds = 'notification_ids';

  // Singleton class setup
  MedicationDatabaseHelper._privateConstructor();
  static final MedicationDatabaseHelper instance =
      MedicationDatabaseHelper._privateConstructor();

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

  // CRUD operations

  // MedicationPlan
  Future<int> insertMedicationPlan(MedicationPlan medicationPlan) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationPlans);
    return await store.add(db, medicationPlan.toMap());
  }

  Future<MedicationPlan?> getMedicationPlan(int id) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationPlans);
    var record = store.record(id);
    var recordValue = await record.get(db);
    if (recordValue == null) {
      return null;
    }
    if (recordValue.containsValue(null)) {
      return null;
    }
    return MedicationPlan.fromMap(recordValue);
  }

  Future<void> updateMedicationPlan(MedicationPlan medicationPlan) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationPlans);
    debugPrint(medicationPlan.toMap().toString());
    debugPrint(medicationPlan.id.runtimeType.toString());
    var record = store.record(medicationPlan.id!);
    await record.update(db, medicationPlan.toMap());
  }

  Future<int> deleteMedicationPlan(MedicationPlan medicationPlan) async {
    for (MedicationComponentPlan componentPlan
        in medicationPlan.medicationComponentPlans) {
      if (componentPlan.notificationIdsToDates.isNotEmpty) {
        await deleteNotificationIds(
            componentPlan.notificationIdsToDates.keys.toList());
      }
    }
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationPlans);
    return await store.delete(db,
        finder: Finder(filter: Filter.byKey(medicationPlan.id)));
  }

  Future<int> deleteMedicationPlanWithId(int id) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationPlans);
    return await store.delete(db, finder: Finder(filter: Filter.byKey(id)));
  }

  Future<List<MedicationPlan>> getAllMedicationPlans() async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationPlans);
    var results = await store.find(db);
    return results.map((e) {
      MedicationPlan plan = MedicationPlan.fromMap(e.value);
      plan.id = e.key;
      return plan;
    }).toList();
  }

  Future<void> deleteDatabase() async {
    await _deleteDatabase();
  }

  Future<List<int>> getNotificationIds(int count) async {
    Database db = await instance.database;
    var store = StoreRef.main();

    // Explicitly create a mutable list from the database value
    var record = await store.record('notificationIds').get(db);

    Map existingIdsMap = {};
    if (record != null) {
      existingIdsMap = record as Map;
    }

    List<int> newIds = [];

    if (existingIdsMap.isEmpty) {
      for (int i = 1; i <= count; i++) {
        newIds.add(i);
      }
      await store.record('notificationIds').put(db, {'ids': newIds});
    } else {
      List<int> mutableExistingIds = List<int>.from(existingIdsMap['ids']);
      int currentValue = 1;
      while (newIds.length < count) {
        if (!existingIdsMap['ids'].contains(currentValue)) {
          mutableExistingIds.add(currentValue);
          newIds.add(currentValue);
        }
        currentValue++;
      }

      // Save the updated list back to the database
      await store
          .record('notificationIds')
          .update(db, {'ids': mutableExistingIds});
    }

    return newIds;
  }

  Future<void> deleteNotificationIds(List<int> notificationIds) async {
    Database db = await instance.database;
    var store = StoreRef.main();

    // Explicitly create a mutable list from the database value
    var existingIdsMap = await store.record('notificationIds').get(db) as Map;

    if (existingIdsMap.isEmpty) {
      return;
    }

    List<int> mutableExistingIds = List<int>.from(existingIdsMap['ids']);

    // Remove the notification IDs that are meant to be deleted
    mutableExistingIds.removeWhere((id) => notificationIds.contains(id));

    // Save the updated list back to the database
    await store
        .record('notificationIds')
        .update(db, {'ids': mutableExistingIds});
  }

  Future<int> insertMedicationComponent(
      MedicationComponent medicationComponent) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationComponents);
    return await store.add(db, medicationComponent.toMap());
  }

  Future<MedicationComponent?> getMedicationComponent(int id) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationComponents);
    var record = store.record(id);
    var recordValue = await record.get(db);
    if (recordValue == null) {
      return null;
    }
    if (recordValue.containsValue(null)) {
      return null;
    }
    return MedicationComponent.fromMap(recordValue);
  }

  Future<int> updateMedicationComponent(
      MedicationComponent medicationComponent) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationComponents);
    return await store.update(db, medicationComponent.toMap(),
        finder: Finder(filter: Filter.byKey(medicationComponent.id)));
  }

  Future<int> deleteMedicationComponent(
      MedicationComponent medicationComponent) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationComponents);
    return await store.delete(db,
        finder: Finder(filter: Filter.byKey(medicationComponent.id)));
  }

  Future<int> deleteMedicationComponentWithId(int id) async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationComponents);
    return await store.delete(db, finder: Finder(filter: Filter.byKey(id)));
  }

  Future<List<MedicationComponent>> getAllMedicationComponents() async {
    Database db = await instance.database;
    var store = intMapStoreFactory.store(tableMedicationComponents);
    var results = await store.find(db);
    return results.map((e) {
      MedicationComponent component = MedicationComponent.fromMap(e.value);
      component.id = e.key;
      return component;
    }).toList();
  }
}
