import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymtrak/utilities/databases/medication_database.dart';
import 'package:gymtrak/utilities/medication/medication_category.dart';
import 'package:gymtrak/utilities/medication/medication_component.dart';
import 'package:gymtrak/utilities/medication/medication_component_plan.dart';
import 'package:gymtrak/utilities/medication/medication_plan.dart';
import 'package:gymtrak/utilities/misc/initial_values.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:numberpicker/numberpicker.dart';

class MedicationBottomSheetWidget extends StatefulWidget {
  final List<String> folders;
  final MedicationPlan? existingPlan;

  const MedicationBottomSheetWidget(
      {Key? key, required this.folders, this.existingPlan})
      : super(key: key);

  @override
  _MedicationBottomSheetWidgetState createState() =>
      _MedicationBottomSheetWidgetState();
}

class _MedicationBottomSheetWidgetState
    extends State<MedicationBottomSheetWidget> {
  late String planName;
  late DateTime planStartDate;
  String? planStartDateString;
  String selectedFolder = 'Select a folder';

  List<String> selectedCategories = [];
  List<MedicationComponentPlan> componentPlans = [];
  List<MedicationComponent> components = [];
  List<MedicationComponent> filteredComponents = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    planName = widget.existingPlan?.name ?? '';
    selectedFolder = widget.existingPlan?.folder ?? 'Select a folder';
    planStartDate = DateTime.now();
    planStartDateString = _formatDate(planStartDate);
    _loadComponents();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.90;
    filteredComponents = _filterComponents();

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Plan Name', 'Enter a name for this plan',
                hintText: planName, onChanged: (value) {
              planName = value;
            }),
            const SizedBox(height: 20),
            _buildFolderDropdown(),
            const SizedBox(height: 20),
            _buildDateTimePicker(),
            Text(planStartDateString ?? 'No Date and Time Chosen'),
            const SizedBox(height: 20),
            _buildCategoryFilterChips(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildComponentList(filteredComponents),
            const SizedBox(height: 20),
          ],
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
      underline: Container(),
      style: const TextStyle(color: Colors.black),
      elevation: 1,
      borderRadius: BorderRadius.circular(15),
    );
  }

  Widget _buildDateTimePicker() {
    return ElevatedButton(
      onPressed: _selectDateTime,
      child: const Text('Select date for start of plan'),
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
      setState(() {
        planStartDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );

        planStartDateString = _formatDate(planStartDate);
      });
    }
  }

  Widget _buildComponentList(List<MedicationComponent> filteredComponents) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredComponents.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final component = filteredComponents[index];
        //final valueExists = componentPlans.containsKey(parameterName);

        return ListTile(
          title: Text(component.name),
          subtitle: Text(component.fullName),
          trailing: IconButton(
            icon: const Icon(Symbols.arrow_right),
            onPressed: () => _showComponentInput(context, component),
          ),
          onTap: () => _showComponentInput(context, component),
        );
      },
    );
  }

  Future<void> _loadComponents() async {
    List<MedicationComponent> loadedComponents =
        await MedicationDatabaseHelper.instance.getAllMedicationComponents();

    if (loadedComponents.isEmpty) {
      for (MedicationComponent component in componentsInitial) {
        await MedicationDatabaseHelper.instance
            .insertMedicationComponent(component);
      }
      loadedComponents =
          await MedicationDatabaseHelper.instance.getAllMedicationComponents();
    }

    setState(() {
      components = loadedComponents;
    });
  }

  List<MedicationComponent> _filterComponents() {
    String searchTerm = searchController.text.toLowerCase();

    return components.where((component) {
      return (selectedCategories.isEmpty ||
              selectedCategories.contains(component.category)) &&
          (searchTerm.isEmpty ||
              component.name.toLowerCase().startsWith(searchTerm) ||
              component.fullName.toLowerCase().startsWith(searchTerm));
    }).toList();
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            categories.map((category) => _buildFilterChip(category)).toList(),
      ),
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
          filteredComponents = _filterComponents();
        });
      },
    );
  }

  void _showComponentInput(
      BuildContext context, MedicationComponent component) {
    showModalBottomSheet<MedicationComponentPlan>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Adjust the height as needed
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30)), // Rounded top edge
            child: Scaffold(
              appBar: AppBar(
                title: Text(component.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              body: MedicationInputSheet(component: component),
            ),
          ),
        );
      },
    );
  }
}

class MedicationInputSheet extends StatefulWidget {
  final MedicationComponent component;

  MedicationInputSheet({required this.component});

  @override
  _MedicationInputSheetState createState() => _MedicationInputSheetState();
}

class _MedicationInputSheetState extends State<MedicationInputSheet> {
  TextEditingController textEditingController = TextEditingController();
  Map<String, bool> daysSelected = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  String? timeString;
  int selectedInterval = 0;
  double? dosage;
  ExpansionTileController regularIntervalController = ExpansionTileController();
  ExpansionTileController certainDaysController = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Dosage',
                    suffixText: widget.component.unit,
                    alignLabelWithHint: true,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(30)],
                  maxLines: 1,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      dosage = double.tryParse(value);
                    });
                  }),
              const SizedBox(height: 20),
              _buildTimePicker(),
              const Text('Select time of intake'),
              const SizedBox(height: 20),
              Theme(
                data: ThemeData(dividerColor: Colors.black26),
                child: ExpansionTile(
                  title: selectedInterval == 0
                      ? const Text('Regular Interval')
                      : Text('Regular Interval: every $selectedInterval. day'),
                  children: [
                    _buildRegularIntervalSelector(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Theme(
                data: ThemeData(dividerColor: Colors.black26),
                child: ExpansionTile(
                  title: const Text('Certain Days'),
                  controller: certainDaysController,
                  onExpansionChanged: (value) {
                    if (value) {
                      if (selectedInterval > 0) {
                        certainDaysController.collapse();
                      }
                    }
                  },
                  children: [
                    _buildCertainDaysSelector(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 40),
      ),
      onPressed: _selectTime,
      child: Text(timeString ?? 'Select time for intake'),
    );
  }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        timeString = pickedTime.format(context);
      });
    }
  }

  Widget _buildRegularIntervalSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        NumberPicker(
          value: selectedInterval,
          minValue: 0,
          maxValue: 99,
          step: 1,
          itemWidth: 150,
          axis: Axis.vertical,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black54, width: 0.5),
          ),
          //textMapper: (String number) => '$number days',
          onChanged: (newValue) {
            setState(() {
              if (selectedInterval != newValue) {
                selectedInterval = newValue;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildCertainDaysSelector() {
    return Column(
      children: daysSelected.keys.map((String day) {
        return CheckboxListTile(
          title: Text(day),
          value: daysSelected[day],
          onChanged: (bool? value) {
            setState(() {
              daysSelected[day] = value!;
            });
          },
        );
      }).toList(),
    );
  }
}
