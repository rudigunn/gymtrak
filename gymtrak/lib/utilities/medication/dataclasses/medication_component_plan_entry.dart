import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan.dart';

class MedicationComponentPlanEntry {
  DateTime intakeDate;
  MedicationComponentPlan medicationComponentPlan;

  MedicationComponentPlanEntry({
    required this.intakeDate,
    required this.medicationComponentPlan,
  });

  Map<String, dynamic> toMap() {
    return {
      'intakeDate': intakeDate.toIso8601String(),
      'medicationComponentPlan': medicationComponentPlan.toMap(),
    };
  }

  factory MedicationComponentPlanEntry.fromMap(Map<String, dynamic> map) {
    return MedicationComponentPlanEntry(
      intakeDate: DateTime.parse(map['intakeDate']),
      medicationComponentPlan: MedicationComponentPlan.fromMap(map['medicationComponentPlan']),
    );
  }
}
