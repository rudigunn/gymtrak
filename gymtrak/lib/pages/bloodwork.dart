import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_botom_sheet.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_result.dart';
import 'package:gymtrak/utilities/databases/bloodwork_database.dart';
import 'package:gymtrak/utilities/databases/general_database.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';

class UserBloodWorkPage extends StatefulWidget {
  const UserBloodWorkPage({super.key});

  @override
  State<UserBloodWorkPage> createState() => _UserBloodWorkPageState();
}

class _UserBloodWorkPageState extends State<UserBloodWorkPage> {
  Map<int, String> folders = {};
  List<BloodWorkResult> results = [];
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
                  'Manage Blood Work',
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
                    _showAddTestResultSheet(context, null);
                  },
                  icon: const Icon(
                    Symbols.add,
                    color: Colors.white,
                  ),
                  label: const Text('Test result'),
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
                        'Blood Work Results',
                        style: TextStyle(fontSize: 20),
                      ),
                      Theme(
                        data: ThemeData(splashFactory: NoSplash.splashFactory),
                        child: IconButton(
                          icon: const Icon(Icons.create_new_folder, color: Colors.black87),
                          onPressed: () async {
                            _addNewFolder();
                            debugPrint(((await getApplicationDocumentsDirectory()).toString()));
                          },
                        ),
                      ),
                    ],
                  )),
            ),
            ..._buildResultExpansionTiles(),
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
    List<BloodWorkResult> data = await BloodWorkDatabaseHelper.instance.getAllBloodWorkResults();
    setState(() {
      results = data;
    });
  }

  void loadFolders() async {
    Map<int, String> data = await GeneralDatabase.instance.readAllFolders();

    if (data.isEmpty) {
      data = {await GeneralDatabase.instance.createFolder('My Results'): 'My Results'};
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
                  int i = await GeneralDatabase.instance.createFolder(_folderNameController.text);
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

  void _showAddTestResultSheet(BuildContext context, BloodWorkResult? existingResult) {
    showModalBottomSheet<BloodWorkResult>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          folders: folders.values.toList(),
          existingResult: existingResult,
        );
      },
    ).then((BloodWorkResult? result) async {
      if (result != null) {
        debugPrint('Received BloodWorkResult: ${result.toString()}');
        if (result.id == null) {
          result.id = await BloodWorkDatabaseHelper.instance.insertBloodWorkResult(result);
        } else {
          await BloodWorkDatabaseHelper.instance.updateBloodWorkResult(result);
        }

        if (result.id != 0) {
          setState(() {
            if (results.any((element) => element.id == result.id)) {
              results[results.indexWhere((element) => element.id == result.id)] = result;
            } else {
              results.add(result);
            }
          });
        }
      }
    });
  }

  List<Widget> _buildResultExpansionTiles() {
    return folders.entries.toList().map((entry) {
      String folder = entry.value;
      int folderId = entry.key;
      List<BloodWorkResult> filteredResults = results.where((result) => result.folder == folder).toList();

      return ExpansionTile(
        title: Text(
          folder,
          style: const TextStyle(fontSize: 18),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        trailing: _buildPopupMenuButton(context, folderId),
        children: [
          _buildResultsList(filteredResults),
        ],
      );
    }).toList();
  }

  Widget _buildPopupMenuButton(BuildContext context, int folderId) {
    return Theme(
      data: ThemeData(splashFactory: NoSplash.splashFactory),
      child: PopupMenuButton(
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

  Widget _buildResultsList(List<BloodWorkResult> filteredResults) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        BloodWorkResult result = filteredResults[index];
        DateFormat format = DateFormat('dd/MM/yyyy HH:mm');

        return Dismissible(
          key: Key(result.id.toString()),
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
            await BloodWorkDatabaseHelper.instance.deleteBloodWorkResult(result.id!);
            setState(() {
              results.remove(result);
            });
          },
          child: ListTile(
            title: Text(result.name),
            subtitle: Text(format.format(result.date)),
            trailing: IconButton(
              icon: const Icon(Symbols.arrow_right),
              color: Colors.black,
              onPressed: () {
                _showAddTestResultSheet(context, result);
              },
            ),
          ),
        );
      },
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

    int i = await GeneralDatabase.instance.updateFolder(folderId, newName);
    if (i != 0) {
      List<BloodWorkResult> updatedResults = [];
      for (var result in results) {
        if (result.folder == folders[folderId]) {
          result.folder = newName;
          await BloodWorkDatabaseHelper.instance.updateBloodWorkResult(result);
          updatedResults.add(result);
        }
      }

      setState(() {
        folders[folderId] = newName;
        results = updatedResults;
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
    int deletionCount = await GeneralDatabase.instance.deleteFolder(folderId);
    if (deletionCount != 0) {
      List<BloodWorkResult> remainingResults = [];

      for (var result in results) {
        if (result.folder == folders[folderId]) {
          await BloodWorkDatabaseHelper.instance.deleteBloodWorkResult(result.id!);
        } else {
          remainingResults.add(result);
        }
      }

      setState(() {
        results = remainingResults;
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
      child: Text(text),
      onPressed: onPressed,
    );
  }
}
