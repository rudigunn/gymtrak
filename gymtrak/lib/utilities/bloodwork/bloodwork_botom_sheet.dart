import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_parameter.dart';
import 'package:intl/intl.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_category.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_result.dart';
import 'package:material_symbols_icons/symbols.dart';

class BottomSheetWidget extends StatefulWidget {
  final List<String> folders;
  const BottomSheetWidget({super.key, required this.folders});

  @override
  State<StatefulWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  String selectedFolder = 'Select a folder';
  String? testName;
  String? testDate;
  List<String> selectedCategories = [];

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
            const SizedBox(height: 20),
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
                      var format = DateFormat('dd/MM/yyyy HH:mm');
                      testDate = format.format(DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      ));
                    });
                  }
                }
              },
              child: const Text('Select Date and Time'),
            ),
            Text(testDate ?? 'No Date and Time Chosen'),
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
                            selectedShadowColor: Colors.green,
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
                      .toList(), // Convert the iterable to a list here
                )),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredParameters.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredParameters[index].name),
                  subtitle: Text(filteredParameters[index].fullName),
                  trailing: IconButton(
                    icon: const Icon(Symbols.arrow_right),
                    color: Colors.black,
                    onPressed: () {},
                  ),
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
                BloodWorkResult newTestResult = BloodWorkResult(
                  folder: selectedFolder,
                  name: testName,
                );

                selectedFolder = 'Select a folder';
                testName = null;

                debugPrint(newTestResult.toString());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
