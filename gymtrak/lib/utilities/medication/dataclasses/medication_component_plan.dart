import 'package:gymtrak/utilities/medication/dataclasses/medication_component.dart';

class MedicationComponentPlan {
  double dosage;
  String type;
  String time;
  double frequency;
  bool notificationsEnabled;
  Map<int, String> notificationIdsToDates = {};
  List<String> intakeDays = [];
  MedicationComponent medicationComponent;

  MedicationComponentPlan({
    required this.dosage,
    required this.type,
    required this.time,
    required this.frequency,
    required this.notificationsEnabled,
    required this.notificationIdsToDates,
    required this.intakeDays,
    required this.medicationComponent,
  });

  Map<String, dynamic> toMap() {
    return {
      'dosage': dosage.toString(),
      'type': type,
      'time': time,
      'frequency': frequency,
      'notificationsEnabled': notificationsEnabled,
      'notificationIdsToDates': notificationIdsToDates.map((key, value) => MapEntry(key.toString(), value)),
      'intakeDays': intakeDays,
      'medicationComponent': medicationComponent.toMap(),
    };
  }

  factory MedicationComponentPlan.fromMap(Map<String, dynamic> map) {
    return MedicationComponentPlan(
      dosage: double.tryParse(map['dosage'].toString()) ?? 0.0,
      type: map['type'],
      time: map['time'],
      frequency: double.tryParse(map['frequency'].toString()) ?? 0.0,
      notificationsEnabled: map['notificationsEnabled'],
      notificationIdsToDates: Map<int, String>.from(
          map['notificationIdsToDates']?.map((key, value) => MapEntry(int.tryParse(key) ?? 0, value)) ?? {}),
      intakeDays: List<String>.from(map['intakeDays'] ?? []),
      medicationComponent: MedicationComponent.fromMap(map['medicationComponent'] ?? {}),
    );
  }
}
