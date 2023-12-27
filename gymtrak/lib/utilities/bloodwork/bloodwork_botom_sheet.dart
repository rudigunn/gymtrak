import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_parameter.dart';
import 'package:intl/intl.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_category.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_result.dart';
import 'package:material_symbols_icons/symbols.dart';

class BottomSheetWidget extends StatefulWidget {
  final List<String> folders;
  final BloodWorkResult? existingResult;

  const BottomSheetWidget({super.key, required this.folders, this.existingResult});

  @override
  State<StatefulWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  String selectedFolder = 'Select a folder';
  List<String> selectedCategories = [];
  late String testName;
  late DateTime testDate;
  String? testDateString;
  Map<String, double> parameterValues = {};

  @override
  void initState() {
    super.initState();
    if (widget.existingResult != null) {
      testName = widget.existingResult!.name;
      selectedFolder = widget.existingResult!.folder;
      testDate = widget.existingResult!.date;
      parameterValues = widget.existingResult!.parameterValues;
      var format = DateFormat('dd/MM/yyyy HH:mm');
      testDateString = format.format(testDate);
    } else {
      testName = '';
      testDate = DateTime.now();
      parameterValues = {};
      testDateString = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.90;
    final List<BloodWorkParameter> filteredParameters = parameters.where((parameter) {
      return selectedCategories.isEmpty || selectedCategories.contains(parameter.category);
    }).toList();

    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
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
            const SizedBox(height: 5),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Test Name',
              ),
              onChanged: (String value) {
                testName = value;
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              items: widget.folders.map((String folder) {
                return DropdownMenuItem<String>(
                  value: folder,
                  child: Text(folder),
                );
              }).toList(),
              hint: Text(selectedFolder),
              onChanged: (String? value) {
                setState(() {
                  selectedFolder = value ?? 'Select a folder';
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      testDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      var format = DateFormat('dd/MM/yyyy HH:mm');
                      testDateString = format.format(testDate);
                    });
                  }
                }
              },
              child: const Text('Select Date and Time'),
            ),
            Text(testDateString ?? 'No Date and Time Chosen'),
            const SizedBox(height: 20),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: categories
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategories.contains(category),
                            onSelected: (isSelected) {
                              setState(() {
                                if (isSelected) {
                                  selectedCategories.add(category);
                                } else {
                                  selectedCategories.remove(category);
                                }
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                )),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredParameters.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final parameter = filteredParameters[index];
                final parameterName = parameter.name;
                final valueExists = parameterValues.containsKey(parameterName);

                return ListTile(
                  title: Text(parameter.name),
                  subtitle: Text(parameter.fullName),
                  trailing: valueExists
                      ? Text('${parameterValues[parameterName]!} ${parameter.unit}',
                          style: const TextStyle(fontSize: 16, color: Colors.black54))
                      : IconButton(
                          icon: const Icon(Symbols.arrow_right),
                          onPressed: () => _showParameterInput(parameter),
                        ),
                  onTap: () => _showParameterInput(parameter),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(75, 45),
                  splashFactory: NoSplash.splashFactory),
              onPressed: () {
                if (widget.existingResult != null) {
                  widget.existingResult!.name = testName;
                  widget.existingResult!.folder = selectedFolder;
                  widget.existingResult!.date = testDate;
                  widget.existingResult!.parameterValues = parameterValues;

                  selectedFolder = 'Select a folder';
                  testName = '';

                  debugPrint(widget.existingResult.toString());
                  Navigator.pop(context, widget.existingResult);
                } else {
                  BloodWorkResult newTestResult = BloodWorkResult(
                    name: testName,
                    folder: selectedFolder,
                    date: testDate,
                    parameterValues: parameterValues,
                  );

                  selectedFolder = 'Select a folder';
                  testName = '';

                  debugPrint(newTestResult.toString());
                  Navigator.pop(context, newTestResult);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showParameterInput(BloodWorkParameter parameter) async {
    double? value = await showDialog<double>(
      context: context,
      builder: (context) {
        TextEditingController textEditingController = TextEditingController();
        return AlertDialog(
          title: Text(parameter.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textEditingController,
                decoration: InputDecoration(labelText: 'Enter Value', suffixText: parameter.unit),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String inputValue = textEditingController.text.replaceAll(',', '.');
                try {
                  double convertedValue = double.parse(inputValue);
                  Navigator.pop(context, convertedValue);
                } catch (e) {
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content: const Text('Please enter a valid number.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              textEditingController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Save Value'),
            ),
          ],
        );
      },
    );

    if (value != null) {
      setState(() {
        parameterValues[parameter.name] = value;
        debugPrint(parameterValues.toString());
      });
    }
  }
}
