import 'dart:convert';
import 'package:gymtrak/utilities/databases/bloodwork_database.dart';

class BloodWorkResult {
  int? id;
  String name;
  String folder;
  DateTime date;
  Map<String, double> parameterValues = {};

  BloodWorkResult({
    this.id,
    required this.name,
    required this.folder,
    required this.date,
    required this.parameterValues,
  });

  BloodWorkResult.fromMap(Map<String, dynamic> map)
      : id = map[BloodWorkDatabaseHelper.columnId],
        name = map[BloodWorkDatabaseHelper.columnName],
        folder = map[BloodWorkDatabaseHelper.columnFolder],
        date = DateTime.parse(map[BloodWorkDatabaseHelper.columnDate]),
        parameterValues = json.decode(map[BloodWorkDatabaseHelper.columnParameterValues]);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      BloodWorkDatabaseHelper.columnName: name,
      BloodWorkDatabaseHelper.columnFolder: folder,
      BloodWorkDatabaseHelper.columnDate: date.toIso8601String(),
      BloodWorkDatabaseHelper.columnParameterValues: json.encode(parameterValues),
    };

    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'TestResult{id: $id, name: $name, folder: $folder, date: $date, parameterValues: $parameterValues}';
  }
}
