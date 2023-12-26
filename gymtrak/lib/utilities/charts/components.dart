class Component {
  final int id;
  final String name;
  final int dosage;

  const Component({
    required this.id,
    required this.name,
    required this.dosage,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
    };
  }

  @override
  String toString() {
    return 'Component{id: $id, name: $name, dosage: $dosage}';
  }
}
