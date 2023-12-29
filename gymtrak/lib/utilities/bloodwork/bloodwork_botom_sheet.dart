import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_parameter.dart';
import 'package:gymtrak/utilities/databases/general_database.dart';
import 'package:gymtrak/utilities/misc/initial_values.dart';
import 'package:intl/intl.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_category.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_result.dart';
import 'package:material_symbols_icons/symbols.dart';

class BottomSheetWidget extends StatefulWidget {
  final List<String> folders;
  final BloodWorkResult? existingResult;

  const BottomSheetWidget({Key? key, required this.folders, this.existingResult}) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late String testName;
  late DateTime testDate;
  String? testDateString;
  String selectedFolder = 'Select a folder';

  List<String> selectedCategories = [];
  Map<String, double> parameterValues = {};
  Map<int, BloodWorkParameter> parameters = {};
  List<BloodWorkParameter> filteredParameters = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    testName = widget.existingResult?.name ?? '';
    selectedFolder = widget.existingResult?.folder ?? 'Select a folder';
    testDate = widget.existingResult?.date ?? DateTime.now();
    parameterValues = widget.existingResult?.parameterValues ?? {};
    testDateString = _formatDate(testDate);
    _loadParameters();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.90;
    filteredParameters = _filterParameters();

    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSeparator(),
            const SizedBox(height: 5),
            _buildTextField('Test Name', 'Enter a name for this test', hintText: testName, onChanged: (value) {
              testName = value;
            }),
            const SizedBox(height: 20),
            _buildFolderDropdown(),
            const SizedBox(height: 20),
            _buildDateTimePicker(),
            Text(testDateString ?? 'No Date and Time Chosen'),
            const SizedBox(height: 20),
            _buildCategoryFilterChips(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildParameterList(filteredParameters),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Center(
      child: Container(
        width: 100,
        height: 4,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 190, 190, 190),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, String helperText,
      {String? hintText, required ValueChanged<String> onChanged}) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText,
        hintText: hintText,
        alignLabelWithHint: true,
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(30)],
      maxLines: 1,
      onChanged: onChanged,
    );
  }

  Widget _buildFolderDropdown() {
    return DropdownButton<String>(
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
    );
  }

  Widget _buildDateTimePicker() {
    return ElevatedButton(
      onPressed: _selectDateTime,
      child: const Text('Select Date and Time'),
    );
  }

  void _selectDateTime() async {
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

          testDateString = _formatDate(testDate);
        });
      }
    }
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((category) => _buildFilterChip(category)).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      decoration: const InputDecoration(
        labelText: 'Search Parameters',
        prefixIcon: Icon(Icons.search),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
      onChanged: (value) {
        setState(() {
          filteredParameters = _filterParameters();
        });
      },
    );
  }

  Widget _buildFilterChip(String category) {
    return Padding(
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
    );
  }

  List<BloodWorkParameter> _filterParameters() {
    String searchTerm = searchController.text.toLowerCase();

    return parameters.values.where((parameter) {
      return (selectedCategories.isEmpty || selectedCategories.contains(parameter.category)) &&
          (searchTerm.isEmpty ||
              parameter.name.toLowerCase().startsWith(searchTerm) ||
              parameter.fullName.toLowerCase().startsWith(searchTerm));
    }).toList();
  }

  Widget _buildParameterList(List<BloodWorkParameter> filteredParameters) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredParameters.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final parameter = filteredParameters[index];
        final parameterName = parameter.name;
        final valueExists = parameterValues.containsKey(parameterName);

        return ListTile(
          title: Text(parameterName),
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
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15, color: Colors.white),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(75, 45),
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: _saveBloodWorkResult,
      child: const Text('Save'),
    );
  }

  Future<void> _showParameterInput(BloodWorkParameter parameter) async {
    TextEditingController textEditingController = TextEditingController();

    double? value = await showDialog<double>(
      context: context,
      builder: (context) {
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

  Future<void> _loadParameters() async {
    Map<int, BloodWorkParameter> loadedParameters = await GeneralDatabase.instance.readAllBloodWorkParameters();

    if (loadedParameters.isEmpty) {
      for (BloodWorkParameter parameter in parametersInitial) {
        await GeneralDatabase.instance.createBloodWorkParameter(parameter);
      }
      loadedParameters = await GeneralDatabase.instance.readAllBloodWorkParameters();
    }

    setState(() {
      parameters = loadedParameters;
    });
  }

  Future<void> _saveBloodWorkResult() async {
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
  }
}
