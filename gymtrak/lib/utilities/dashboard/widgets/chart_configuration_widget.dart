import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/bloodwork/dataclasses/bloodwork_result.dart';
import 'package:gymtrak/utilities/dashboard/widgets/query_configuration.dart';
import 'package:gymtrak/utilities/databases/bloodwork_database.dart';
import 'package:gymtrak/utilities/databases/medication_database.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan_entry.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartConfigurationWidget extends StatefulWidget {
  const ChartConfigurationWidget({super.key});

  @override
  ChartConfigurationWidgetState createState() =>
      ChartConfigurationWidgetState();
}

class ChartConfigurationWidgetState extends State<ChartConfigurationWidget> {
  String? selectedDataSource;
  String? selectedEntry;
  String? selectedTransformation;
  List<String> transformationOptions = ['mean', 'moving average'];

  List<BloodWorkResult> bloodworkOptions = [];
  List<MedicationComponentPlanEntry> medicationOptions = [];

  List<QueryConfiguration> queries = [QueryConfiguration()];

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ...queries.asMap().entries.map((entry) {
                int idx = entry.key;
                //QueryConfiguration query = entry.value;
                return Column(
                  children: [
                    _buildDataSourceSelector(idx),
                    const SizedBox(height: 20),
                    _buildDataEntrySelector(idx),
                    const SizedBox(height: 20),
                    _buildTransformationSelector(idx),
                    const SizedBox(height: 20),
                    if (queries.length > 1)
                      ElevatedButton(
                        onPressed: () => _removeQuery(idx),
                        child: const Text('Remove Query'),
                      ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addQuery,
                child: const Text('Add Another Query'),
              ),
              const SizedBox(height: 20),
              _buildChartPreview(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSourceSelector(int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("FROM",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 60),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              items: const [
                DropdownMenuItem<String>(
                  value: 'Bloodwork',
                  child: Text('Bloodwork'),
                ),
                DropdownMenuItem<String>(
                  value: 'Medication',
                  child: Text('Medication'),
                )
              ],
              hint: queries[idx].selectedDataSource == null
                  ? const Text('Select a datasource')
                  : Text(queries[idx].selectedDataSource!),
              onChanged: (String? value) {
                setState(() {
                  queries[idx].selectedDataSource = value;
                  fetchDataAndTransform();
                });
              },
              underline: Container(),
              style: const TextStyle(color: Colors.black),
              elevation: 1,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataEntrySelector(int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("WHAT",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 60),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              items: queries[idx].selectedDataSource == 'Bloodwork'
                  ? bloodworkOptions
                      .expand((result) => result.parameterValues.keys)
                      .toSet()
                      .toList()
                      .map((name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ))
                      .toList()
                  : medicationOptions
                      .map((entry) => entry
                          .medicationComponentPlan.medicationComponent.name)
                      .toSet()
                      .toList()
                      .map((name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
              hint: queries[idx].selectedEntry == null
                  ? const Text('Select a entry')
                  : Text(queries[idx].selectedEntry!),
              onChanged: (String? value) {
                setState(() {
                  queries[idx].selectedEntry = value;
                });
              },
              underline: Container(),
              style: const TextStyle(color: Colors.black),
              elevation: 1,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationSelector(int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("MAPPING",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 60),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              items: transformationOptions.map((String transformation) {
                return DropdownMenuItem<String>(
                  value: transformation,
                  child: Text(transformation),
                );
              }).toList(),
              hint: queries[idx].selectedTransformation == null
                  ? const Text('Select a transformation')
                  : Text(queries[idx].selectedTransformation!),
              onChanged: (String? value) {
                setState(() {
                  queries[idx].selectedTransformation = value;
                });
              },
              underline: Container(),
              style: const TextStyle(color: Colors.black),
              elevation: 1,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPreview() {
    List<LineSeries<dynamic, dynamic>> seriesList = queries.map((query) {
      List<_ChartData> data = [];
      if (query.selectedDataSource == null || query.selectedEntry == null) {
        return LineSeries<_ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          name: query.selectedEntry ?? 'Series',
        );
      } else if (query.selectedDataSource == 'Bloodwork') {
        List<BloodWorkResult> bloodworkResults = bloodworkOptions;
        List<_ChartData> data = bloodworkResults
            .where((result) =>
                result.parameterValues.containsKey(query.selectedEntry))
            .map((result) => _ChartData(
                result.date, result.parameterValues[query.selectedEntry]!))
            .toList();
        return LineSeries<_ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          name: query.selectedEntry ?? 'Series',
        );
      } else if (query.selectedDataSource == 'Medication') {
        List<MedicationComponentPlanEntry> medicationComponentPlanEntries =
            medicationOptions;
        List<_ChartData> data = medicationComponentPlanEntries
            .where((entry) =>
                entry.medicationComponentPlan.medicationComponent.name ==
                query.selectedEntry)
            .map((entry) => _ChartData(
                entry.intakeDate, entry.medicationComponentPlan.dosage))
            .toList();
        return LineSeries<_ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          name: query.selectedEntry ?? 'Series',
        );
      }

      return LineSeries<_ChartData, DateTime>(
        dataSource: data,
        xValueMapper: (_ChartData data, _) => data.x,
        yValueMapper: (_ChartData data, _) => data.y,
        name: query.selectedEntry ?? 'Series',
      );
    }).toList();

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      title: const ChartTitle(text: 'Chart Preview'),
      legend: const Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: seriesList,
    );
  }

  void fetchDataAndTransform() {
    _fetchDataAndTransform();
  }

  Future<void> _fetchDataAndTransform() async {
    if (queries.map((e) => e.selectedDataSource).contains('Bloodwork')) {
      List<BloodWorkResult> bloodworkResults =
          await BloodWorkDatabaseHelper.instance.getAllBloodWorkResults();
      setState(() {
        bloodworkOptions = bloodworkResults;
      });
    }
    if (queries.map((e) => e.selectedDataSource).contains('Medication')) {
      List<MedicationComponentPlanEntry> medicationComponentPlanEntries =
          await MedicationDatabaseHelper.instance
              .getAllMedicationComponentPlanEntries();
      setState(() {
        medicationOptions = medicationComponentPlanEntries;
      });
    }
  }

  void _addQuery() {
    setState(() {
      queries.add(QueryConfiguration());
    });
  }

  void _removeQuery(int index) {
    setState(() {
      queries.removeAt(index);
    });
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
