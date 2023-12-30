import 'package:gymtrak/utilities/medication/medication_component.dart';
import 'package:gymtrak/utilities/medication/medication_component_plan.dart';
import 'package:gymtrak/utilities/medication/medication_plan.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/databases/general_database.dart';
import 'package:gymtrak/utilities/databases/medication_database.dart';
import 'package:material_symbols_icons/symbols.dart';

class UserMedicationPage extends StatefulWidget {
  const UserMedicationPage({super.key});

  @override
  State<UserMedicationPage> createState() => _UserMedicationPageState();
}

class _UserMedicationPageState extends State<UserMedicationPage> {
  Map<int, String> folders = {};
  List<MedicationPlan> plans = [];

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
                    //_showAddTestResultSheet(context, null);
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
                        'Medication Components',
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
            ..._buildComponentExpansionTiles(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _folderNameController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  void loadData() async {
    List<MedicationPlan> data = [];
    // check if data is empty and add a default plan
    if (data.isEmpty) {
      MedicationPlan medicationPlan = MedicationPlan(
        name: 'My Medications',
        folder: 'My Medications',
        description: 'My Medications',
        active: true,
        medicationComponentPlanMap: {
          2: MedicationComponentPlan(
              type: 'Injection',
              dosage: 0,
              frequency: 0,
              medicationComponent: MedicationComponent(
                  name: 'Medication', fullName: 'Medication', unit: 'mg', typeToHalfLife: {'Injection': 4.5}))
        },
      );

      await MedicationDatabaseHelper.instance.insertMedicationPlan(medicationPlan);

      data = await MedicationDatabaseHelper.instance.getAllMedicationPlans();
    }
    setState(() {
      plans = data;
      debugPrint('Got plans from database');
      debugPrint(plans.toString());
      debugPrint('');
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
                Navigator.of(context).pop(); // Close the dialog
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

  List<Widget> _buildComponentExpansionTiles() {
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
            _buildPlansList(filteredPlans),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPlansList(List<MedicationPlan> filteredPlans) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        MedicationPlan plan = filteredPlans[index];
        DateFormat format = DateFormat('dd/MM/yyyy HH:mm');

        return Dismissible(
          key: Key(plan.id.toString()),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20.0),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            //await .instance.deleteBloodWorkResult(result.id!);
            setState(() {
              //results.remove(result);
            });
          },
          child: ListTile(
            title: Text(plan.name),
            subtitle: Text(plan.description!),
            trailing: IconButton(
              icon: const Icon(Symbols.arrow_right),
              color: Colors.black,
              onPressed: () {
                //_showAddTestResultSheet(context, result);
              },
            ),
          ),
        );
      },
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
          //TODO: Update database
          //await MedicationDatabaseHelper.instance.updateMedicationComponent(component.value);
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
          // TODO: Delete from database
          //await MedicationDatabaseHelper.instance.deleteMedicationComponent(component.key!);
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
}
