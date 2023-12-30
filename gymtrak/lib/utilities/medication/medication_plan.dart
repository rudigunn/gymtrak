import 'dart:convert';

import 'package:gymtrak/utilities/medication/medication_component_plan.dart';

class MedicationPlan {
  int? id;
  String name;
  String folder;
  String description;
  bool active;
  Map<int, MedicationComponentPlan> medicationComponentPlanMap = {};

  MedicationPlan({
    this.id,
    required this.name,
    required this.folder,
    required this.active,
    required this.medicationComponentPlanMap,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folder': folder,
      'description': description,
      'active': active ? 1 : 0,
      'medicationComponentPlanMap':
          json.encode(medicationComponentPlanMap.map((key, value) => MapEntry(key.toString(), value.toMap())))
    };
  }

  // Convert database Map to MedicationPlan object
  factory MedicationPlan.fromMap(Map<String, dynamic> map) {
    return MedicationPlan(
        id: map['id'],
        name: map['name'],
        folder: map['folder'],
        description: map['description'],
        active: map['active'] == 1,
        medicationComponentPlanMap: (json.decode(map['medicationComponentPlanMap'] as String) as Map<String, dynamic>)
            .map((key, value) =>
                MapEntry(int.parse(key), MedicationComponentPlan.fromMap(value as Map<String, dynamic>))));
  }
}
