import 'package:gymtrak/utilities/medication/medication_component.dart';

class MedicationComponentPlan {
  double dosage;
  String type;
  String time;
  double frequency;
  Map<int, String> notificationIdsToDates = {};
  List<String> intakeDays = [];
  List<int> notificationIds = [];
  MedicationComponent medicationComponent;

  MedicationComponentPlan({
    required this.dosage,
    required this.type,
    required this.time,
    required this.frequency,
    required this.notificationIdsToDates,
    required this.intakeDays,
    required this.notificationIds,
    required this.medicationComponent,
  });

  Map<String, dynamic> toMap() {
    return {
      'dosage': dosage.toString(),
      'type': type,
      'time': time,
      'frequency': frequency,
      'notificatinIdsToDates': notificationIdsToDates,
      'intakeDays': intakeDays,
      'notificationIds': notificationIds,
      'medicationComponent': medicationComponent.toMap(),
    };
  }

  factory MedicationComponentPlan.fromMap(Map<String, dynamic> map) {
    return MedicationComponentPlan(
      dosage: double.tryParse(map['dosage']) ?? 0.0,
      type: map['type'],
      time: map['time'],
      frequency: map['frequency'],
      notificationIdsToDates: map['notificationIdsAndDates'] == null
          ? {}
          : Map<int, String>.from(map['notificationIdsAndDates']),
      intakeDays: List<String>.from(map['intakeDays']),
      notificationIds: List<int>.from(map['notificationIds']),
      medicationComponent:
          MedicationComponent.fromMap(map['medicationComponent']),
    );
  }
}
