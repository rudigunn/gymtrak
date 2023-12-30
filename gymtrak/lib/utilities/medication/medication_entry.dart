import 'package:gymtrak/utilities/medication/medication_component.dart';

class MedicationEntry {
  int? id;
  String? notes;
  double dosage;
  DateTime date;
  MedicationComponent medicationComponent;

  MedicationEntry({
    this.id,
    this.notes,
    required this.dosage,
    required this.date,
    required this.medicationComponent,
  });

  MedicationEntry.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        notes = map['notes'],
        dosage = map['dosage'],
        date = DateTime.parse(map['date']),
        medicationComponent = MedicationComponent.fromMap(map);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'notes': notes,
      'dosage': dosage,
      'date': date.toIso8601String(),
      'medicationComponent': medicationComponent.toMap(),
    };

    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
