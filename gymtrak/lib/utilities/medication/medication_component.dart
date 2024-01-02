class MedicationComponent {
  int? id;
  String name;
  String fullName;
  String category;
  String unit;
  Map<String, double> typeToHalfLife = {};

  MedicationComponent({
    this.id,
    required this.name,
    required this.fullName,
    required this.category,
    required this.unit,
    required this.typeToHalfLife,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': fullName,
      'category': category,
      'unit': unit,
      'typeToHalfLife': typeToHalfLife,
    };
  }

  factory MedicationComponent.fromMap(Map<String, dynamic> map) {
    return MedicationComponent(
      name: map['name'],
      fullName: map['fullName'],
      category: map['category'],
      unit: map['unit'],
      typeToHalfLife: map['typeToHalfLife'].cast<String, double>(),
    );
  }
}
