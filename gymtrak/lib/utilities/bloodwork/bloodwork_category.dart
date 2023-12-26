enum ParameterCategory { heart, blood, kidney, liver, electrolytes, vitaminesAndTraceElements}

class Category {
  static const Map<ParameterCategory, String> names = {
    ParameterCategory.heart: 'Cardiovascular System',
    ParameterCategory.blood: 'Blood',
    ParameterCategory.kidney: 'Kidney',
    ParameterCategory.liver: 'Liver',
    ParameterCategory.electrolytes: 'Electrolytes',
    ParameterCategory.vitaminesAndTraceElements: 'Vitamins + Trace Elements',
  };

  static String getName(ParameterCategory type) => names[type]!;
}

final List<String> categories = [
  'Cardiovascular System',
  'Blood',
  'Kidney',
  'Liver',
  'Electrolytes',
  'Vitamins + Trace Elements',
];