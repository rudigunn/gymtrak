import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/gestures.dart';
import 'package:gymtrak/data.dart';
import 'package:gymtrak/utilities/charts/charts.dart';
import 'package:gymtrak/utilities/dashboard/widgets/chart_configuration_widget.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  UserDashBoardPageState createState() => UserDashBoardPageState();
}

class UserDashBoardPageState extends State<UserDashboardPage> {
  final GlobalKey<ChartConfigurationWidgetState> chartConfigurationSheetKey =
      GlobalKey<ChartConfigurationWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Theme(
          data: ThemeData(splashFactory: NoSplash.splashFactory),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notification_important_outlined),
            splashColor: Colors.transparent,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 45),
                  splashFactory: NoSplash.splashFactory),
              onPressed: () async => await _showDataSourceSelectionSheet(context),
              icon: const Icon(
                Symbols.add,
                color: Colors.white,
              ),
              label: const Text('New chart'),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: CardWidget(
                  chartConfig: ChartConfiguration(
                    data: complexGroupData,
                    variables: {
                      'date': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
                          return map['date']?.toString() ?? '';
                        },
                        scale: OrdinalScale(tickCount: 0, inflate: true),
                      ),
                      'points': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
                          return map['points'] as num;
                        },
                      ),
                      'name': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
                          return map['name']?.toString() ?? '';
                        },
                      ),
                    },
                    coord: RectCoord(horizontalRange: [0.01, 0.99]),
                    marks: [
                      LineMark(
                        position: Varset('date') * Varset('points') / Varset('name'),
                        shape: ShapeEncode(value: BasicLineShape(smooth: true)),
                        size: SizeEncode(value: 0.5),
                        color: ColorEncode(
                          variable: 'name',
                          values: Defaults.colors10,
                          updaters: {
                            'groupMouse': {false: (color) => color.withAlpha(100)},
                            'groupTouch': {false: (color) => color.withAlpha(100)},
                          },
                        ),
                      ),
                      PointMark(
                        color: ColorEncode(
                          variable: 'name',
                          values: Defaults.colors10,
                          updaters: {
                            'groupMouse': {false: (color) => color.withAlpha(100)},
                            'groupTouch': {false: (color) => color.withAlpha(100)},
                          },
                        ),
                      ),
                    ],
                    axes: [
                      Defaults.horizontalAxis,
                      Defaults.verticalAxis,
                    ],
                    selections: {
                      'tooltipMouse': PointSelection(on: {
                        GestureType.hover,
                      }, devices: {
                        PointerDeviceKind.mouse
                      }),
                      'groupMouse': PointSelection(
                          on: {
                            GestureType.hover,
                          },
                          variable: 'name',
                          devices: {PointerDeviceKind.mouse}),
                      'tooltipTouch': PointSelection(
                          on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
                          devices: {PointerDeviceKind.touch}),
                      'groupTouch': PointSelection(
                          on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
                          variable: 'name',
                          devices: {PointerDeviceKind.touch}),
                    },
                    tooltip: TooltipGuide(
                      selections: {'tooltipTouch', 'tooltipMouse'},
                      followPointer: [true, true],
                      align: Alignment.topLeft,
                      mark: 0,
                      variables: [
                        'date',
                        'name',
                        'points',
                      ],
                    ),
                    crosshair: CrosshairGuide(
                      selections: {'tooltipTouch', 'tooltipMouse'},
                      styles: [
                        PaintStyle(strokeColor: const Color(0xffbfbfbf)),
                        PaintStyle(strokeColor: const Color(0x00bfbfbf)),
                      ],
                      followPointer: [true, false],
                    ),
                  ),
                ));
          }
          return null;
        },
      ),
    );
  }

  _showDataSourceSelectionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Scaffold(
              appBar: AppBar(
                title: Center(
                  child: Container(
                    width: 100,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 190, 190, 190),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        Navigator.pop(context);
                        // Logic to save the chart
                      }),
                ],
              ),
              body: ChartConfigurationWidget(
                key: chartConfigurationSheetKey,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  final ChartConfiguration chartConfig;

  const CardWidget({
    super.key,
    required this.chartConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      surfaceTintColor: Colors.white,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                title: Text('Card Title'),
                subtitle: Text('Subtitle'),
              ),
              LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  height: 150,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Chart(
                      data: chartConfig.data,
                      variables: chartConfig.variables,
                      marks: chartConfig.marks,
                      axes: chartConfig.axes,
                      selections: chartConfig.selections,
                      tooltip: chartConfig.tooltip,
                      crosshair: chartConfig.crosshair,
                    ),
                  ),
                );
              }),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Some text at the bottom'),
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Theme(
                data: ThemeData(splashFactory: NoSplash.splashFactory),
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Handle settings button tap
                  },
                ),
              )),
        ],
      ),
    );
  }
}
