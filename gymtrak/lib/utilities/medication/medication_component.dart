import 'dart:convert';

class MedicationComponent {
  int? id;
  String name;
  String fullName;
  String unit;
  Map<String, double> typeToHalfLife = {};

  MedicationComponent({
    this.id,
    required this.name,
    required this.fullName,
    required this.unit,
    required this.typeToHalfLife,
  });

  // Convert MedicationComponent to Map for database storage
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'fullName': fullName, 'unit': unit, 'typeToHalfLife': json.encode(typeToHalfLife)};
  }

  factory MedicationComponent.fromMap(Map<String, dynamic> map) {
    return MedicationComponent(
        id: map['id'] as int?,
        name: map['name'] as String,
        fullName: map['fullName'] as String,
        unit: map['unit'] as String,
        typeToHalfLife:
            (map['halfLife'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as double)) ?? {});
  }
}
