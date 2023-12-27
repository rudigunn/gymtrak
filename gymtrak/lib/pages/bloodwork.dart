import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_botom_sheet.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_result.dart';
import 'package:gymtrak/utilities/databases/bloodwork_database.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';

class UserBloodWorkPage extends StatefulWidget {
  const UserBloodWorkPage({super.key});

  @override
  State<UserBloodWorkPage> createState() => _UserBloodWorkPageState();
}

class _UserBloodWorkPageState extends State<UserBloodWorkPage> {
  List<String> folders = ['Default Folder'];
  List<BloodWorkResult> results = [];
  final TextEditingController _folderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
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
              onPressed: () {
                if (_folderNameController.text.isNotEmpty) {
                  setState(() {
                    folders.add(_folderNameController.text);
                    _folderNameController.clear();
                  });
                  Navigator.of(context).pop();
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
          folders: folders,
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

        if (result.id != null) {
          setState(() {
            results.add(result);
          });
        }
      }
    });
  }

  List<Widget> _buildResultExpansionTiles() {
    return folders.map((folder) {
      List<BloodWorkResult> filteredResults = results.where((result) => result.folder == folder).toList();

      return ExpansionTile(
        title: Text(
          folder,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: Theme(
          data: ThemeData(splashFactory: NoSplash.splashFactory),
          child: IconButton(
            icon: const Icon(Symbols.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              BloodWorkResult result = filteredResults[index];
              DateFormat format = DateFormat('dd/MM/yyyy HH:mm');

              return ListTile(
                title: Text(result.name),
                subtitle: Text(format.format(result.date)),
                trailing: IconButton(
                  icon: const Icon(Symbols.arrow_right),
                  color: Colors.black,
                  onPressed: () {
                    _showAddTestResultSheet(context, result);
                  },
                ),
              );
            },
          ),
        ],
      );
    }).toList();
  }
}
