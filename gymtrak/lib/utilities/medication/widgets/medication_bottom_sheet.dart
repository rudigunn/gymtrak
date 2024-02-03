import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymtrak/utilities/databases/medication_database.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_category.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_plan.dart';
import 'package:gymtrak/utilities/misc/initial_values.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:numberpicker/numberpicker.dart';

class MedicationBottomSheetWidget extends StatefulWidget {
  final List<String> folders;
  final MedicationPlan? existingPlan;

  const MedicationBottomSheetWidget({super.key, required this.folders, this.existingPlan});

  @override
  MedicationBottomSheetWidgetState createState() => MedicationBottomSheetWidgetState();
}

class MedicationBottomSheetWidgetState extends State<MedicationBottomSheetWidget> {
  int? planId;
  late String planName;
  DateTime planStartDate = DateTime.now();
  String? planStartDateString;
  String? planLastRefreshedDateString;
  String selectedFolder = 'Select a folder';
  bool startDateEnabled = true;

  List<String> selectedCategories = [];
  List<MedicationComponentPlan> componentPlans = [];
  List<MedicationComponent> components = [];
  List<MedicationComponent> filteredComponents = [];
  GlobalKey<MedicationInputSheetState> medicationInputKey = GlobalKey();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController planNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    planId = widget.existingPlan?.id;
    planName = widget.existingPlan?.name ?? '';
    planNameController.text = planName;
    planLastRefreshedDateString = widget.existingPlan?.lastRefreshedDateString ?? '';
    selectedFolder = widget.existingPlan?.folder ?? 'Select a folder';
    componentPlans = widget.existingPlan?.medicationComponentPlans ?? [];
    if (widget.existingPlan != null) {
      planStartDateString = widget.existingPlan!.startDateString;
      planStartDate = _convertStringToDate(planStartDateString!);
      startDateEnabled = false;
    } else {
      planStartDateString = planStartDate.toIso8601String();
    }
    _loadComponents();
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
            _buildTextField(
              'Plan Name',
              'Enter a name for this plan',
              hintText: planName,
              onChanged: (value) {
                setState(() {
                  planName = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildFolderDropdown(),
            const SizedBox(height: 20),
            _buildDateTimePicker(),
            Text('Selected: ${DateFormat('dd.MM.yyyy').format(planStartDate)}'),
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
      controller: planNameController,
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
    return IgnorePointer(
      ignoring: !startDateEnabled,
      child: Opacity(
        opacity: startDateEnabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: _selectDateTime,
          child: const Text('Select date for start of plan'),
        ),
      ),
    );
  }

  void _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: planStartDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        planStartDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );

        planStartDateString = planStartDate.toIso8601String();
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
        MedicationComponentPlan? matchingComponentPlan = componentPlans.firstWhereOrNull(
          (element) => element.medicationComponent.id == component.id,
        );

        double? componentDosage = matchingComponentPlan?.dosage;

        return ListTile(
          title: Text(component.name),
          subtitle: Text(component.fullName),
          trailing: matchingComponentPlan != null
              ? Text('$componentDosage ${component.unit}', style: const TextStyle(fontSize: 16, color: Colors.black54))
              : IconButton(
                  icon: const Icon(Symbols.arrow_right),
                  onPressed: () => _showComponentInput(context, component, matchingComponentPlan),
                ),
          onTap: () => _showComponentInput(context, component, matchingComponentPlan),
        );
      },
    );
  }

  Future<void> _loadComponents() async {
    List<MedicationComponent> loadedComponents = await MedicationDatabaseHelper.instance.getAllMedicationComponents();

    if (loadedComponents.isEmpty) {
      for (MedicationComponent component in componentsInitial) {
        await MedicationDatabaseHelper.instance.insertMedicationComponent(component);
      }
      loadedComponents = await MedicationDatabaseHelper.instance.getAllMedicationComponents();
    }

    setState(() {
      components = loadedComponents;
    });
  }

  List<MedicationComponent> _filterComponents() {
    String searchTerm = searchController.text.toLowerCase();

    return components.where((component) {
      return (selectedCategories.isEmpty || selectedCategories.contains(component.category)) &&
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
        children: categories.map((category) => _buildFilterChip(category)).toList(),
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
      BuildContext context, MedicationComponent component, MedicationComponentPlan? medicationComponentPlan) async {
    MedicationComponentPlan? componentPlan = await showModalBottomSheet<MedicationComponentPlan>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Scaffold(
              appBar: AppBar(
                title: Align(
                  alignment: Alignment.center,
                  child: Text(component.name),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      MedicationInputSheetState? state = medicationInputKey.currentState;
                      if (state != null) {
                        double? dosage = state.dosage;
                        String? selectedType = state.selectedType;
                        String? timeString = state.timeString;
                        int selectedInterval = state.selectedInterval;
                        bool notificationsEnabled = state.notificationsEnabled;
                        Map<String, bool> daysSelected = state.daysSelected;

                        if (dosage == null || dosage <= 0) {
                          debugPrint(state.dosage.toString());
                          _showErrorDialog(context, 'Please enter a valid dosage.');
                          return;
                        }

                        if (selectedType == null || selectedType.isEmpty) {
                          _showErrorDialog(context, 'Please select a type.');
                          return;
                        }

                        if (timeString == null || timeString.isEmpty) {
                          _showErrorDialog(context, 'Please select a time for intake.');
                          return;
                        }

                        if (selectedInterval == 0 && !daysSelected.containsValue(true)) {
                          _showErrorDialog(context, 'Please select a regular interval or specific days.');
                          return;
                        }

                        MedicationComponentPlan componentPlan = MedicationComponentPlan(
                          dosage: dosage,
                          type: selectedType,
                          time: timeString,
                          frequency: selectedInterval > 0 ? selectedInterval.toDouble() : 0.0,
                          notificationsEnabled: notificationsEnabled,
                          notificationIdsToDates: {},
                          intakeDays: daysSelected.keys.where((day) => daysSelected[day]!).toList(),
                          medicationComponent: component,
                        );

                        Navigator.of(context).pop(componentPlan);
                      }
                    },
                  ),
                ],
              ),
              body: MedicationInputSheet(
                  key: medicationInputKey, component: component, componentPlan: medicationComponentPlan),
            ),
          ),
        );
      },
    );

    if (componentPlan != null) {
      setState(() {
        MedicationComponentPlan? existingComponentPlan = componentPlans.firstWhereOrNull(
          (element) => element.medicationComponent.id == componentPlan.medicationComponent.id,
        );
        if (existingComponentPlan != null) {
          componentPlans.remove(existingComponentPlan);
        }
        componentPlans.add(componentPlan);
        debugPrint('Added component plan: ${componentPlans.toString()}');
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  DateTime _convertStringToDate(String date) {
    return DateTime.parse(date);
  }
}

class MedicationInputSheet extends StatefulWidget {
  final MedicationComponent component;
  final MedicationComponentPlan? componentPlan;

  const MedicationInputSheet({super.key, required this.component, required this.componentPlan});

  @override
  MedicationInputSheetState createState() => MedicationInputSheetState();
}

class MedicationInputSheetState extends State<MedicationInputSheet> {
  double? dosage;
  String? selectedType;
  String? timeString;
  int selectedInterval = 0;
  bool notificationsEnabled = false;
  Map<String, bool> daysSelected = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  bool expansionTileEnabled = true;

  TextEditingController textEditingController = TextEditingController();
  ExpansionTileController regularIntervalController = ExpansionTileController();
  ExpansionTileController certainDaysController = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    if (widget.componentPlan != null) {
      dosage = widget.componentPlan!.dosage;
      textEditingController.text = widget.componentPlan!.dosage.toString();
      selectedType = widget.componentPlan!.type;
      timeString = widget.componentPlan!.time;
      notificationsEnabled = widget.componentPlan!.notificationsEnabled;
      selectedInterval = widget.componentPlan!.frequency == 0 ? 0 : (widget.componentPlan!.frequency).round();
      for (String day in widget.componentPlan!.intakeDays) {
        daysSelected[day] = true;
      }
      expansionTileEnabled = selectedInterval == 0 && !daysSelected.containsValue(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDosageInputField(),
              const SizedBox(height: 20),
              _buildTypeSelector(),
              const SizedBox(height: 20),
              _buildTimePickerWidget(),
              const SizedBox(height: 20),
              _buildEnableNotificationsSelected(),
              const SizedBox(height: 20),
              _buildRegularIntervalSelectorWidget(),
              const SizedBox(height: 20),
              _buildCertainDaysSelectorWidget(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Widget _buildDosageInputField() {
    return TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: 'Enter Dosage',
          suffixText: widget.component.unit,
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(30)],
        maxLines: 1,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          setState(() {
            dosage = double.tryParse(value.replaceAll(',', '.'));
            debugPrint(dosage.toString());
          });
        });
  }

  Widget _buildTimePickerWidget() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 40),
          ),
          onPressed: _selectTime,
          child: Text(timeString ?? 'Select time for intake'),
        ),
      ],
    );
  }

  Widget _buildRegularIntervalSelectorWidget() {
    return Theme(
      data: ThemeData(dividerColor: Colors.black26),
      child: IgnorePointer(
        ignoring: !expansionTileEnabled,
        child: Opacity(
          opacity: !expansionTileEnabled ? 0.5 : 1.0,
          child: ExpansionTile(
            title: selectedInterval == 0
                ? const Text('Regular Interval')
                : Text('Regular Interval: every $selectedInterval. day'),
            controller: regularIntervalController,
            onExpansionChanged: (value) {
              if (value) {
                if (daysSelected.containsValue(true)) {
                  _showErrorDialog(
                      context, 'You have already selected certain days. Please deselect them to continue.');
                  regularIntervalController.collapse();
                }
              }
            },
            children: [
              _buildRegularIntervalSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertainDaysSelectorWidget() {
    String selectedDaysString = '';
    if (daysSelected.values.every((element) => element)) {
      selectedDaysString = 'Every day';
    } else {
      for (String day in daysSelected.keys) {
        if (daysSelected[day]!) {
          selectedDaysString += '$day, ';
        }
      }
      if (selectedDaysString.isNotEmpty) {
        selectedDaysString = selectedDaysString.substring(0, selectedDaysString.length - 2);
      }
    }
    return Theme(
      data: ThemeData(dividerColor: Colors.black26),
      child: IgnorePointer(
        ignoring: !expansionTileEnabled,
        child: Opacity(
          opacity: !expansionTileEnabled ? 0.5 : 1.0,
          child: ExpansionTile(
            title: selectedDaysString.isEmpty ? const Text('Certain Days') : Text('Certain Days: $selectedDaysString'),
            controller: certainDaysController,
            onExpansionChanged: (value) {
              if (value) {
                if (selectedInterval > 0) {
                  _showErrorDialog(
                      context, 'You have already selected a regular interval. Please set it to 0 to continue.');
                  certainDaysController.collapse();
                }
              }
            },
            children: [
              _buildCertainDaysSelector(),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context, initialTime: timeString != null ? _convertStringToTimeOfDay(timeString!) : TimeOfDay.now());

    if (pickedTime != null) {
      setState(() {
        timeString = _formatTimeOfDay(pickedTime, context);
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    return DropdownButton<String>(
      items: widget.component.typeToHalfLife.keys.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      hint: selectedType == null ? const Text('Select a type') : Text(selectedType!),
      onChanged: (String? value) {
        setState(() {
          selectedType = value;
        });
      },
      underline: Container(),
      style: const TextStyle(color: Colors.black),
      elevation: 1,
      borderRadius: BorderRadius.circular(15),
    );
  }

  Widget _buildEnableNotificationsSelected() {
    return SwitchListTile(
      title: const Text('Enable Notifications'),
      subtitle:
          const Text('If enabled, the app will send you notifications at the specified days at the specified time'),
      value: notificationsEnabled,
      onChanged: (bool value) {
        setState(() {
          notificationsEnabled = value;
        });
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay, BuildContext context) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(dateTime);
  }

  TimeOfDay _convertStringToTimeOfDay(String time) {
    final format = DateFormat.jm();
    DateTime? dateTime = format.parseStrict(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
