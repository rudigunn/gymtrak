import 'package:gymtrak/utilities/medication/medication_bottom_sheet.dart';
import 'package:gymtrak/utilities/medication/medication_plan.dart';
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
                      textStyle:
                          const TextStyle(fontSize: 15, color: Colors.white),
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
                          icon: const Icon(Icons.create_new_folder,
                              color: Colors.black87),
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
    List<MedicationPlan> data = [];
    data = await MedicationDatabaseHelper.instance.getAllMedicationPlans();
    setState(() {
      plans = data;
    });
  }

  void loadFolders() async {
    Map<int, String> data = await GeneralDatabase.instance
        .readAllFolders(GeneralDatabase.tableMedicationFolders);

    if (data.isEmpty) {
      data = {
        await GeneralDatabase.instance.createFolder(
                'My Medications', GeneralDatabase.tableMedicationFolders):
            'My Medications'
      };
    }
    setState(() {
      folders = data;
    });
  }

  void _showAddMedicationPlanSheet(
      BuildContext context, MedicationPlan? existingPlan) {
    showModalBottomSheet<MedicationPlan>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // return MedicationBottomSheetWidget(
        //   folders: folders.values.toList(),
        //   existingPlan: existingPlan,
        // );
        return FractionallySizedBox(
          heightFactor: 0.9, // Adjust the height as needed
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30)), // Rounded top edge
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              body: MedicationBottomSheetWidget(
                folders: folders.values.toList(),
                existingPlan: existingPlan,
              ),
            ),
          ),
        );
      },
    ).then((MedicationPlan? plan) async {
      if (plan != null) {
        debugPrint('Received MedicationPlan: ${plan.toString()}');
        if (plan.id == null) {
          plan.id = await MedicationDatabaseHelper.instance
              .insertMedicationPlan(plan);
        } else {
          await MedicationDatabaseHelper.instance.updateMedicationPlan(plan);
        }

        if (plan.id != 0) {
          setState(() {
            if (plans.any((element) => element.id == plan.id)) {
              plans[plans.indexWhere((element) => element.id == plan.id)] =
                  plan;
            } else {
              plans.add(plan);
            }
          });
        }
      }
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
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 172, 172, 172)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 114, 114, 114)),
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
                  int i = await GeneralDatabase.instance.createFolder(
                      _folderNameController.text,
                      GeneralDatabase.tableMedicationFolders);
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
      List<MedicationPlan> filteredPlans =
          plans.where((plan) => plan.folder == folder).toList();

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
      ),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        MedicationPlan plan = filteredPlans[index];
        //DateFormat format = DateFormat('dd/MM/yyyy HH:mm');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Card(
            child: Dismissible(
              key: Key(plan.id.toString()),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10.0),
                color: Colors.red,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                await MedicationDatabaseHelper.instance
                    .deleteMedicationPlanWithId(plan.id!);
                setState(() {
                  plans.remove(plan);
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(plan.name),
                  Text(plan.description),
                  IconButton(
                    icon: const Icon(Symbols.arrow_right),
                    color: Colors.black,
                    onPressed: () {
                      _showAddMedicationPlanSheet(context, plan);
                    },
                  ),
                ],
              ),
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
              onPressed: () =>
                  _handleRenameSave(renameController.text, folderId),
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

    int i = await GeneralDatabase.instance.updateFolder(
        folderId, newName, GeneralDatabase.tableMedicationFolders);
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
    int deletionCount = await GeneralDatabase.instance
        .deleteFolder(folderId, GeneralDatabase.tableMedicationFolders);
    if (deletionCount != 0) {
      List<MedicationPlan> remainingPlans = [];

      for (var plan in plans) {
        if (plan.folder == folders[folderId]) {
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

  Widget _buildDialogButton(
      {required String text, required void Function()? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
