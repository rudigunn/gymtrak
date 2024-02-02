import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan.dart';

class MedicationPlan {
  int? id;
  String name;
  String folder;
  String description;
  String startDateString;
  String lastRefreshedDateString;
  bool active;
  List<MedicationComponentPlan> medicationComponentPlans = [];

  MedicationPlan({
    this.id,
    required this.name,
    required this.folder,
    required this.description,
    required this.startDateString,
    required this.lastRefreshedDateString,
    required this.active,
    required this.medicationComponentPlans,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'name': name,
      'folder': folder,
      'startDateString': startDateString,
      'lastRefreshedDateString': lastRefreshedDateString,
      'active': active,
      'description': description,
      'medicationComponentPlanMap': medicationComponentPlans.map((e) => e.toMap()).toList(),
    };
  }

  factory MedicationPlan.fromMap(Map<String, dynamic> map) {
    final id = map['id'] == null ? null : int.tryParse(map['id']);
    debugPrint(map['id']);
    if (id == null && map['id'] != null) {
      throw FormatException('Invalid format for id: ${map['id']}');
    }

    return MedicationPlan(
      id: id,
      name: map['name'],
      folder: map['folder'],
      startDateString: map['startDateString'],
      lastRefreshedDateString: map['lastRefreshedDateString'],
      active: map['active'],
      description: map['description'],
      medicationComponentPlans: (map['medicationComponentPlanMap'] as List<dynamic>)
          .map((e) => MedicationComponentPlan.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  void printFieldTypes() {
    debugPrint('id: ${id.runtimeType}');
    debugPrint('name: ${name.runtimeType}');
    debugPrint('folder: ${folder.runtimeType}');
    debugPrint('description: ${description.runtimeType}');
    debugPrint('startDateString: ${startDateString.runtimeType}');
    debugPrint('lastRefreshedDateString: ${lastRefreshedDateString.runtimeType}');
    debugPrint('active: ${active.runtimeType}');
    debugPrint('medicationComponentPlans: ${medicationComponentPlans.runtimeType}');
  }
}
