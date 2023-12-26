import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/gestures.dart';
import 'package:gymtrak/data.dart';
import 'package:gymtrak/utilities/charts/charts.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

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
              onPressed: () {},
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: CardWidget(
                  chartConfig: ChartConfiguration(
                    data: complexGroupData,
                    variables: {
                      'date': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map =
                              data as Map<dynamic, dynamic>;
                          return map['date']?.toString() ?? '';
                        },
                        scale: OrdinalScale(tickCount: 0, inflate: true),
                      ),
                      'points': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map =
                              data as Map<dynamic, dynamic>;
                          return map['points'] as num;
                        },
                      ),
                      'name': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map =
                              data as Map<dynamic, dynamic>;
                          return map['name']?.toString() ?? '';
                        },
                      ),
                    },
                    coord: RectCoord(horizontalRange: [0.01, 0.99]),
                    marks: [
                      LineMark(
                        position:
                            Varset('date') * Varset('points') / Varset('name'),
                        shape: ShapeEncode(value: BasicLineShape(smooth: true)),
                        size: SizeEncode(value: 0.5),
                        color: ColorEncode(
                          variable: 'name',
                          values: Defaults.colors10,
                          updaters: {
                            'groupMouse': {
                              false: (color) => color.withAlpha(100)
                            },
                            'groupTouch': {
                              false: (color) => color.withAlpha(100)
                            },
                          },
                        ),
                      ),
                      PointMark(
                        color: ColorEncode(
                          variable: 'name',
                          values: Defaults.colors10,
                          updaters: {
                            'groupMouse': {
                              false: (color) => color.withAlpha(100)
                            },
                            'groupTouch': {
                              false: (color) => color.withAlpha(100)
                            },
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
                      'tooltipTouch': PointSelection(on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      }, devices: {
                        PointerDeviceKind.touch
                      }),
                      'groupTouch': PointSelection(
                          on: {
                            GestureType.scaleUpdate,
                            GestureType.tapDown,
                            GestureType.longPressMoveUpdate
                          },
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
          } else if (index == 1) {
            return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: CardWidget(
                  chartConfig: ChartConfiguration(
                    data: adjustData,
                    variables: {
                      'index': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map =
                              data as Map<dynamic, dynamic>;
                          return map['index'].toString();
                        },
                      ),
                      'type': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map =
                              data as Map<dynamic, dynamic>;
                          return map['type'] as String;
                        },
                      ),
                      'value': Variable(
                        accessor: (dynamic data) {
                          final Map<dynamic, dynamic> map =
                              data as Map<dynamic, dynamic>;
                          return map['value'] as num;
                        },
                      ),
                    },
                    coord: PolarCoord(),
                    marks: [
                      LineMark(
                        position:
                            Varset('index') * Varset('value') / Varset('type'),
                        shape: ShapeEncode(value: BasicLineShape(loop: true)),
                        color: ColorEncode(
                            variable: 'type', values: Defaults.colors10),
                      )
                    ],
                    axes: [
                      Defaults.circularAxis,
                      Defaults.radialAxis,
                    ],
                    selections: {
                      'touchMove': PointSelection(
                        on: {
                          GestureType.scaleUpdate,
                          GestureType.tapDown,
                          GestureType.longPressMoveUpdate
                        },
                        dim: Dim.x,
                        variable: 'index',
                      )
                    },
                    tooltip: TooltipGuide(
                      anchor: (_) => Offset.zero,
                      align: Alignment.bottomRight,
                      multiTuples: true,
                      variables: ['type', 'value'],
                    ),
                    crosshair: CrosshairGuide(followPointer: [false, true]),
                  ),
                ));
          }
          return null;
        },
      ),
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
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
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
