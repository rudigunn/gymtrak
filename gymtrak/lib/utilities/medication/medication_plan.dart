import 'package:gymtrak/utilities/medication/medication_component_plan.dart';

class MedicationPlan {
  int? id;
  String name;
  String folder;
  String description;
  bool active;
  List<MedicationComponentPlan> medicationComponentPlans = [];

  MedicationPlan({
    this.id,
    required this.name,
    required this.folder,
    required this.active,
    required this.medicationComponentPlans,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folder': folder,
      'active': active,
      'description': description,
      'medicationComponentPlanMap':
          medicationComponentPlans.map((e) => e.toMap()).toList(),
    };
  }

  factory MedicationPlan.fromMap(Map<String, dynamic> map) {
    return MedicationPlan(
      id: map['id'],
      name: map['name'],
      folder: map['folder'],
      active: map['active'],
      description: map['description'],
      medicationComponentPlans: List<MedicationComponentPlan>.from(
          map['medicationComponentPlanMap']
              .map((e) => MedicationComponentPlan.fromMap(e))),
    );
  }
}
