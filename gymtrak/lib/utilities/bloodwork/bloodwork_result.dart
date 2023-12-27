class BloodWorkResult {
  String name;
  String folder;
  DateTime date;
  Map<String, double> parameterValues = {};

  BloodWorkResult({required this.name, required this.folder, required this.date, required this.parameterValues});

  @override
  String toString() {
    return 'TestResult{name: $name, date: $date, parameterValues: $parameterValues}';
  }
}
