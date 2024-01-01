import 'package:gymtrak/utilities/medication/medication_component.dart';

class MedicationComponentPlan {
  double frequency;
  double dosage;
  MedicationComponent medicationComponent;

  MedicationComponentPlan({
    required this.frequency,
    required this.dosage,
    required this.medicationComponent,
  });

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'dosage': dosage,
      'medicationComponent': medicationComponent.toMap(),
    };
  }

  factory MedicationComponentPlan.fromMap(Map<String, dynamic> map) {
    return MedicationComponentPlan(
      frequency: map['frequency'],
      dosage: map['dosage'],
      medicationComponent:
          MedicationComponent.fromMap(map['medicationComponent']),
    );
  }
}
