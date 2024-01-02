import 'package:gymtrak/utilities/medication/medication_component.dart';

class MedicationComponentPlan {
  double dosage;
  String type;
  String time;
  double frequency;
  List<String> intakeDays = [];
  MedicationComponent medicationComponent;

  MedicationComponentPlan({
    required this.dosage,
    required this.type,
    required this.time,
    required this.frequency,
    required this.intakeDays,
    required this.medicationComponent,
  });

  Map<String, dynamic> toMap() {
    return {
      'dosage': dosage.toString(),
      'type': type,
      'frequency': frequency,
      'intakeDays': intakeDays,
      'medicationComponent': medicationComponent.toMap(),
    };
  }

  factory MedicationComponentPlan.fromMap(Map<String, dynamic> map) {
    return MedicationComponentPlan(
      dosage: double.tryParse(map['dosage']) ?? 0.0,
      type: map['type'],
      time: map['time'],
      frequency: map['frequency'],
      intakeDays: List<String>.from(map['intakeDays']),
      medicationComponent: MedicationComponent.fromMap(map['medicationComponent']),
    );
  }
}
