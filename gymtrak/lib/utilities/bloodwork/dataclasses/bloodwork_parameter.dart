class BloodWorkParameter {
  int? id;
  String name;
  String fullName;
  String category;
  double upperLimit;
  double lowerLimit;
  String unit;

  BloodWorkParameter({
    this.id,
    required this.name,
    required this.fullName,
    required this.category,
    required this.upperLimit,
    required this.lowerLimit,
    required this.unit,
  });

  BloodWorkParameter.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        fullName = map['fullName'],
        category = map['category'],
        upperLimit = map['upperLimit'],
        lowerLimit = map['lowerLimit'],
        unit = map['unit'];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'fullName': fullName,
      'category': category,
      'upperLimit': upperLimit,
      'lowerLimit': lowerLimit,
      'unit': unit,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
