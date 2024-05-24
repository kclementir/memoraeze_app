import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';

class AddSetsScreen extends StatefulWidget {
  final String folderName;

  const AddSetsScreen({super.key, required this.folderName});

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
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final sets = FolderManager().getAllSets();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2B4057),
            title: Text('Add Sets to ${widget.folderName}', style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView.builder(
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              return Dismissible(
                key: Key(set['title']),
                background: _buildDismissBackground(),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Optionally handle dismiss
                },
                child: GestureDetector(
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
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: FolderBox(
                    folderName: set['title'],
                    description: '${set['terms'].length} terms',
                    descriptionStyle: const TextStyle(color: Color(0xFFC3D1DB), fontSize: 12),
                    showIcon: false,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Build dismiss background widget for Dismissible
  Widget _buildDismissBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 36),
    );
  }
}

class FolderBox extends StatelessWidget {
  final String folderName;
  final String? description;
  final TextStyle? descriptionStyle;
  final bool showIcon;

  const FolderBox({super.key, required this.folderName, this.description, this.descriptionStyle, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2B4057),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: showIcon ? const Icon(Icons.folder_outlined, color: Color(0xFFC3D1DB)) : null,
        title: Text(folderName, style: const TextStyle(color: Color(0xFFC3D1DB))),
        subtitle: description != null ? Text(description!, style: descriptionStyle ?? const TextStyle(color: Color(0xFFC3D1DB))) : null,
      ),
    );
  }
}
