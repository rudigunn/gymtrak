import 'package:flutter/material.dart';

class UserBloodWorkPage extends StatefulWidget {
  const UserBloodWorkPage({super.key});

  @override
  State<UserBloodWorkPage> createState() => _UserBloodWorkPageState();
}

class _UserBloodWorkPageState extends State<UserBloodWorkPage> {
  List<String> folders = ['Vitamin D Tests'];
  final TextEditingController _folderNameController = TextEditingController();

  void _addNewFolder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Folder'),
          content: TextField(
            controller: _folderNameController,
            decoration: const InputDecoration(hintText: "Enter folder name"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
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
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Result'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 150),
                        child: Text(
                          'Blood Work Results',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.create_new_folder, color: Colors.black87),
                        onPressed: () {
                          _addNewFolder();
                        },
                      ),
                    ],
                  )),
            ),
            for (var folder in folders)
              ExpansionTile(
                title: Text(folder),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Result ${index + 1}'),
                      );
                    },
                  ),
                ],
              ),
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
}
