import 'package:gymtrak/utilities/medication/medication_component.dart';

class MedicationComponentPlan {
  String type;
  double frequency;
  double dosage;
  MedicationComponent medicationComponent;

  MedicationComponentPlan({
    required this.type,
    required this.frequency,
    required this.dosage,
    required this.medicationComponent,
  });

  // Convert MedicationComponentPlan to Map for database storage
  Map<String, dynamic> toMap() {
    return {'type': type, 'frequency': frequency, 'dosage': dosage, 'medicationComponent': medicationComponent.toMap()};
  }

  // Convert database Map to MedicationComponentPlan object
  factory MedicationComponentPlan.fromMap(Map<String, dynamic> map) {
    return MedicationComponentPlan(
        type: map['type'] as String,
        frequency: map['frequency'] as double,
        dosage: map['dosage'] as double,
        medicationComponent: MedicationComponent.fromMap(map['medicationComponent'] as Map<String, dynamic>));
  }
}
