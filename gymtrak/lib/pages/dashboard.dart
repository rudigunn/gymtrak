import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/gestures.dart';
import 'package:gymtrak/data.dart';
import 'package:gymtrak/utilities/charts/charts.dart';
import 'package:gymtrak/utilities/dashboard/widgets/chart_configuration_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  UserDashBoardPageState createState() => UserDashBoardPageState();
}

class UserDashBoardPageState extends State<UserDashboardPage> {
  final GlobalKey<ChartConfigurationWidgetState> chartConfigurationSheetKey =
      GlobalKey<ChartConfigurationWidgetState>();

  List<SfCartesianChart> chartConfigurations = [];

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
        itemCount: chartConfigurations.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: CardWidget(
                chartConfig: chartConfigurations[index],
              ));
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
                        var currentConfig = chartConfigurationSheetKey.currentState?.currentChart;
                        if (currentConfig != null) {
                          setState(() {
                            chartConfigurations.add(currentConfig);
                          });
                        }
                        Navigator.pop(context);
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
  final SfCartesianChart chartConfig;

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
                  height: 250,
                  child: SizedBox(width: constraints.maxWidth, height: constraints.maxHeight, child: chartConfig),
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
