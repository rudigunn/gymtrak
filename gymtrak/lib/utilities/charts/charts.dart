import 'package:graphic/graphic.dart';

class ChartConfiguration {
  final List<Map> data;
  final Map<String, Variable> variables;
  final List<Mark> marks;
  final List<AxisGuide<dynamic>> axes;
  final Map<String, Selection> selections;
  final TooltipGuide tooltip;
  final CrosshairGuide crosshair;

  ChartConfiguration({
    required this.data,
    required this.variables,
    required this.marks,
    required this.axes,
    required this.selections,
    required this.tooltip,
    required this.crosshair,
    required Coord coord,
  });

  // Add other necessary fields and methods
}
