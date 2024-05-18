import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';

class AddSetsScreen extends StatefulWidget {
  final String folderName;

  const AddSetsScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  _AddSetsScreenState createState() => _AddSetsScreenState();
}

class _AddSetsScreenState extends State<AddSetsScreen> {
  late Future<void> _loadSetsFuture;

  @override
  void initState() {
    super.initState();
    _loadSetsFuture = FolderManager().loadAllSets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadSetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2B4057),
              title: Text('Add Sets to ${widget.folderName}', style: const TextStyle(color: Colors.white)),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final sets = FolderManager().getAllSets();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2B4057),
            title: Text('Add Sets to ${widget.folderName}', style: const TextStyle(color: Colors.white)),
          ),
          body: ListView.builder(
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                color: const Color(0xFF102F50),
                child: ListTile(
                  title: Text(set['title'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${set['terms'].length} terms', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    FolderManager().addSetToFolder(
                      widget.folderName,
                      set,
                      onDuplicate: (folderName) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF2B4057),
                              title: const Text('Duplicate Set', style: TextStyle(color: Colors.white)),
                              content: Text(
                                'The set is already added to the folder $folderName.',
                                style: const TextStyle(color: Colors.white),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                    // Show a snackbar message on successful addition
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Study set ${set['title']} successfully added'),
                        backgroundColor: const Color(0xFF59A6BF),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
