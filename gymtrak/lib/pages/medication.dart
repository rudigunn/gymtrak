import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:gymtrak/utilities/medication/widgets/medication_bottom_sheet.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_component_plan.dart';
import 'package:gymtrak/utilities/medication/dataclasses/medication_plan.dart';
import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/databases/general_database.dart';
import 'package:gymtrak/utilities/databases/medication_database.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserMedicationPage extends StatefulWidget {
  const UserMedicationPage({super.key});

  @override
  State<UserMedicationPage> createState() => _UserMedicationPageState();
}

class _UserMedicationPageState extends State<UserMedicationPage> {
  Map<int, String> folders = {};
  List<MedicationPlan> plans = [];

  GlobalKey<MedicationBottomSheetWidgetState> medicationBottomSheetKey = GlobalKey();

  final TextEditingController _folderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Manage Medication',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(75, 45),
                      splashFactory: NoSplash.splashFactory),
                  onPressed: () {
                    _showAddMedicationPlanSheet(context, null);
                  },
                  icon: const Icon(
                    Symbols.add,
                    color: Colors.white,
                  ),
                  label: const Text('Medication'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Medication Plans',
                        style: TextStyle(fontSize: 20),
                      ),
                      Theme(
                        data: ThemeData(splashFactory: NoSplash.splashFactory),
                        child: IconButton(
                          icon: const Icon(Icons.create_new_folder, color: Colors.black87),
                          onPressed: () async {
                            _addNewFolder();
                          },
                        ),
                      ),
                    ],
                  )),
            ),
            ..._buildPlanExpansionTiles(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void loadData() async {
    await MedicationDatabaseHelper.instance.deleteDatabase();
    List<MedicationPlan> data = [];
    data = await MedicationDatabaseHelper.instance.getAllMedicationPlans();
    setState(() {
      plans = data;
    });
  }

  void loadFolders() async {
    Map<int, String> data = await GeneralDatabase.instance.readAllFolders(GeneralDatabase.tableMedicationFolders);

    if (data.isEmpty) {
      data = {
        await GeneralDatabase.instance.createFolder('My Medications', GeneralDatabase.tableMedicationFolders):
            'My Medications'
      };
    }
    setState(() {
      folders = data;
    });
  }

  void _showAddMedicationPlanSheet(BuildContext context, MedicationPlan? existingPlan) async {
    MedicationPlan? medicationPlan = await showModalBottomSheet<MedicationPlan>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
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
                      MedicationBottomSheetWidgetState? state = medicationBottomSheetKey.currentState;

                      if (state != null) {
                        if (medicationBottomSheetKey.currentState!.planName.isEmpty) {
                          _showErrorDialog(context, 'Medication plan name cannot be empty');
                          return;
                        }

                        if (medicationBottomSheetKey.currentState!.selectedFolder == 'Select a folder') {
                          _showErrorDialog(context, 'Medication plan folder cannot be empty');
                          return;
                        }

                        DateTime now = DateTime.now();

                        if (state.planStartDate.year == now.year &&
                            state.planStartDate.month == now.month &&
                            state.planStartDate.day == now.day) {
                          _showErrorDialog(context, 'Medication plan start date cannot be empty');
                          return;
                        }

                        List<MedicationComponentPlan> componentPlans = state.componentPlans;
                        if (componentPlans.isNotEmpty) {
                          MedicationPlan medicationPlan = MedicationPlan(
                            id: state.planId,
                            name: state.planName,
                            folder: state.selectedFolder,
                            startDateString: state.planStartDate.toIso8601String(),
                            lastRefreshedDateString: state.planLastRefreshedDateString ?? '',
                            active: true,
                            medicationComponentPlans: componentPlans,
                            description: '',
                          );
                          Navigator.of(context).pop(medicationPlan);
                        } else {
                          _showErrorDialog(context,
                              'Medication plan cannot be empty. Please add at least one medication component.');
                          return;
                        }
                      }
                    },
                  ),
                ],
              ),
              body: MedicationBottomSheetWidget(
                key: medicationBottomSheetKey,
                folders: folders.values.toList(),
                existingPlan: existingPlan,
              ),
            ),
          ),
        );
      },
    );
    if (medicationPlan != null) {
      debugPrint('Received MedicationPlan: ${medicationPlan.toMap()}');
      await handleMedicationPlan(medicationPlan);
    }
  }

  void _addNewFolder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Folder'),
          backgroundColor: Colors.white,
          content: TextField(
            controller: _folderNameController,
            decoration: const InputDecoration(
              hintText: "Enter folder name",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 172, 172, 172)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 114, 114, 114)),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                _folderNameController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () async {
                if (_folderNameController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  int i = await GeneralDatabase.instance
                      .createFolder(_folderNameController.text, GeneralDatabase.tableMedicationFolders);
                  setState(() {
                    if (i != 0) {
                      folders[i] = _folderNameController.text;
                    }
                    _folderNameController.clear();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPlanExpansionTiles() {
    return folders.entries.toList().map((entry) {
      String folder = entry.value;
      int folderId = entry.key;
      List<MedicationPlan> filteredPlans = plans.where((plan) => plan.folder == folder).toList();

      return Theme(
        data: ThemeData(dividerColor: Colors.black26),
        child: ExpansionTile(
          title: Text(
            folder,
            style: const TextStyle(fontSize: 18),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          trailing: _buildPopupMenuButton(context, folderId),
          children: [
            _buildPlanBlocks(filteredPlans),
            const SizedBox(height: 20),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPlanBlocks(List<MedicationPlan> filteredPlans) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        MedicationPlan plan = filteredPlans[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 1,
            child: InkWell(
              onTap: () => _showAddMedicationPlanSheet(context, plan),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        _buildPlanPopupMenuButton(plan, index),
                      ],
                    ),
                    Text(plan.active ? 'Active' : 'Inactive',
                        style: TextStyle(
                            fontSize: 14, color: plan.active ? const Color.fromARGB(255, 112, 186, 115) : Colors.grey)),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            plan.medicationComponentPlans.length > 3 ? 3 + 1 : plan.medicationComponentPlans.length,
                        itemBuilder: (context, componentIndex) {
                          debugPrint("In Block Function");
                          plan.printFieldTypes();
                          if (componentIndex >= 3) {
                            return const Text("...", style: TextStyle(fontSize: 14));
                          }
                          MedicationComponentPlan componentPlan = plan.medicationComponentPlans[componentIndex];
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${componentPlan.medicationComponent.name} ${componentPlan.dosage} ${componentPlan.medicationComponent.unit}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanPopupMenuButton(MedicationPlan plan, int index) {
    return Theme(
      data: ThemeData(splashFactory: NoSplash.splashFactory),
      child: PopupMenuButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(plan.active ? 'Set plan to inactive' : 'Set plan to active'),
            ),
            onTap: () {
              setState(() {
                plan.active = !plan.active;
                MedicationDatabaseHelper.instance.updateMedicationPlan(plan);
              });
            },
          ),
          PopupMenuItem(
            value: 2,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Delete Plan'),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Plan'),
                    content: const Text('Are you sure you want to delete this plan?'),
                    actions: <Widget>[
                      _buildDialogButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                      _buildDialogButton(
                        text: 'Delete',
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            plans.removeAt(index);
                            MedicationDatabaseHelper.instance.deleteMedicationPlanWithId(plan.id!);
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuButton(BuildContext context, int folderId) {
    return Theme(
      data: ThemeData(splashFactory: NoSplash.splashFactory),
      child: PopupMenuButton(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Rename'),
            ),
            onTap: () => _showRenameDialog(context, folderId),
          ),
          PopupMenuItem(
            value: 2,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Delete'),
            ),
            onTap: () => _showDeleteDialog(context, folderId),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, int folderId) {
    TextEditingController renameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: renameController,
                  decoration: const InputDecoration(
                    labelText: 'New Folder Name',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            _buildDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
            _buildDialogButton(
              text: 'Save',
              onPressed: () => _handleRenameSave(renameController.text, folderId),
            ),
          ],
        );
      },
    );
  }

  void _handleRenameSave(String newName, int folderId) async {
    if (newName.isEmpty) {
      _showErrorDialog(context, 'Folder name cannot be empty');
      return;
    }

    Navigator.of(context).pop();

    int i = await GeneralDatabase.instance.updateFolder(folderId, newName, GeneralDatabase.tableMedicationFolders);
    if (i != 0) {
      List<MedicationPlan> updatedPlans = [];
      for (var plan in plans) {
        if (plan.folder == folders[folderId]) {
          plan.folder = newName;
          await MedicationDatabaseHelper.instance.updateMedicationPlan(plan);
          updatedPlans.add(plan);
        }
      }

      setState(() {
        folders[folderId] = newName;
        plans = updatedPlans;
      });
    }
  }

  void _showDeleteDialog(BuildContext context, int folderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Folder'),
          content: const Text('Are you sure you want to delete this folder?'),
          actions: <Widget>[
            _buildDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
            _buildDialogButton(
              text: 'Delete',
              onPressed: () => _handleDelete(folderId),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(int folderId) async {
    Navigator.of(context).pop();
    int deletionCount = await GeneralDatabase.instance.deleteFolder(folderId, GeneralDatabase.tableMedicationFolders);
    if (deletionCount != 0) {
      List<MedicationPlan> remainingPlans = [];

      for (var plan in plans) {
        if (plan.folder == folders[folderId]) {
          await cancelExistingNotifications(plan.id!);
          await MedicationDatabaseHelper.instance.deleteMedicationPlan(plan);
        } else {
          remainingPlans.add(plan);
        }
      }

      setState(() {
        plans = remainingPlans;
        folders.remove(folderId);
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
            _buildDialogButton(
              text: 'OK',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogButton({required String text, required void Function()? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  TimeOfDay _convertStringToTimeOfDay(String time) {
    final format = DateFormat.jm();
    DateTime? dateTime = format.parseStrict(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  int getUniqueId() {
    return DateTime.now().millisecondsSinceEpoch % 2147483647;
  }

  Future<void> handleMedicationPlan(MedicationPlan? medicationPlan) async {
    if (medicationPlan == null) return;

    await _checkAndRequestNotificationPermission();
    String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await _insertOrUpdateMedicationPlan(medicationPlan);

    DateTime now = DateTime.now();
    DateTime startDate = DateTime.parse(medicationPlan.startDateString);

    for (MedicationComponentPlan componentPlan in medicationPlan.medicationComponentPlans) {
      TimeOfDay timeOfDay = _convertStringToTimeOfDay(componentPlan.time);
      await _scheduleNotificationsForComponentPlan(componentPlan, now, startDate, timeOfDay, localTimeZone);
    }

    medicationPlan.lastRefreshedDateString = DateTime.now().toIso8601String();
    await MedicationDatabaseHelper.instance.updateMedicationPlan(medicationPlan);
    _updatePlansList(medicationPlan);
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> _insertOrUpdateMedicationPlan(MedicationPlan medicationPlan) async {
    await MedicationDatabaseHelper.instance.getAllMedicationPlans().then((value) => debugPrint(value.toString()));
    debugPrint('--------------------');
    if (medicationPlan.id == null) {
      int planId = await MedicationDatabaseHelper.instance.insertMedicationPlan(medicationPlan);
      medicationPlan.id = planId;
      await MedicationDatabaseHelper.instance.updateMedicationPlan(medicationPlan);
    } else {
      await MedicationDatabaseHelper.instance.updateMedicationPlan(medicationPlan);
      await cancelExistingNotifications(medicationPlan.id!);
    }
    await MedicationDatabaseHelper.instance.getAllMedicationPlans().then((value) => debugPrint(value.toString()));
    debugPrint('--------------------');
  }

  Future<void> _scheduleNotificationsForComponentPlan(MedicationComponentPlan componentPlan, DateTime now,
      DateTime startDate, TimeOfDay timeOfDay, String localTimeZone) async {
    if (componentPlan.frequency != 0) {
      int numberOfNotifictionsToAdd = 0;
      if (componentPlan.notificationIdsToDates.isNotEmpty) {
        for (MapEntry<int, String> entry in componentPlan.notificationIdsToDates.entries) {
          DateTime notificationDate = DateTime.parse(entry.value);
          if (notificationDate.isAfter(now)) {
            startDate = notificationDate;
            break;
          } else {
            componentPlan.notificationIdsToDates.remove(entry.key);
            await MedicationDatabaseHelper.instance.deleteNotificationIds([entry.key]);
            numberOfNotifictionsToAdd++;
          }
        }
      } else {
        numberOfNotifictionsToAdd = 20;
      }
      List<int> notificationIds = await MedicationDatabaseHelper.instance.getNotificationIds(numberOfNotifictionsToAdd);

      for (int i = 1; i <= numberOfNotifictionsToAdd; i++) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationIds[i - 1],
            channelKey: 'medication_reminder',
            actionType: ActionType.DisabledAction,
            title: 'Medication reminder',
            body: 'You have a medication to take!',
            category: NotificationCategory.Reminder,
          ),
          schedule: NotificationCalendar(
            allowWhileIdle: true,
            repeats: false,
            year: startDate.year,
            month: startDate.month,
            day: startDate.day,
            hour: timeOfDay.hour,
            minute: timeOfDay.minute,
            second: 0,
            timeZone: localTimeZone,
          ),
        );
        componentPlan.notificationIdsToDates[notificationIds[i - 1]] = startDate.toIso8601String();
        startDate = startDate.add(Duration(days: i * componentPlan.frequency.toInt()));
      }
    } else {
      List<int> notificationIds =
          await MedicationDatabaseHelper.instance.getNotificationIds(componentPlan.intakeDays.length);

      Map<String, int> daysToInts = {
        'Monday': DateTime.monday,
        'Tuesday': DateTime.tuesday,
        'Wednesday': DateTime.wednesday,
        'Thursday': DateTime.thursday,
        'Friday': DateTime.friday,
        'Saturday': DateTime.saturday,
        'Sunday': DateTime.sunday,
      };

      for (int i = 0; i < componentPlan.intakeDays.length; i++) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationIds[i],
            channelKey: 'medication_reminder',
            actionType: ActionType.DisabledAction,
            title: 'Medication reminder',
            body: 'You have a medication to take!',
            category: NotificationCategory.Reminder,
          ),
          schedule: NotificationCalendar(
            allowWhileIdle: true,
            repeats: false,
            weekday: daysToInts[componentPlan.intakeDays[i]],
            hour: timeOfDay.hour,
            minute: timeOfDay.minute,
            second: 0,
            timeZone: localTimeZone,
          ),
        );
        componentPlan.notificationIdsToDates[notificationIds[i]] = startDate.toIso8601String();
      }
    }
  }

  void _updatePlansList(MedicationPlan medicationPlan) {
    setState(() {
      if (plans.any((element) => element.id == medicationPlan.id)) {
        plans[plans.indexWhere((element) => element.id == medicationPlan.id)] = medicationPlan;
      } else {
        plans.add(medicationPlan);
      }
    });
  }

  Future<void> cancelExistingNotifications(int planId) async {
    MedicationPlan? medicationPlan = await MedicationDatabaseHelper.instance.getMedicationPlan(planId);

    List<MedicationComponentPlan> components = medicationPlan?.medicationComponentPlans ?? [];
    for (MedicationComponentPlan component in components) {
      if (component.notificationIdsToDates.isNotEmpty) {
        for (int notificationId in component.notificationIdsToDates.keys) {
          await AwesomeNotifications().cancel(notificationId);
        }
      }
    }
  }

  Future<void> refreshReminders() async {
    List<MedicationPlan> allPlans = await MedicationDatabaseHelper.instance.getAllMedicationPlans();

    for (MedicationPlan plan in allPlans) {
      await handleMedicationPlan(plan);
    }
  }
}
