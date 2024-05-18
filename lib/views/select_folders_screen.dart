import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';

class SelectFoldersScreen extends StatefulWidget {
  final Function(List<String>) onFoldersSelected;

  const SelectFoldersScreen({Key? key, required this.onFoldersSelected}) : super(key: key);

  @override
  _SelectFoldersScreenState createState() => _SelectFoldersScreenState();
}

class _SelectFoldersScreenState extends State<SelectFoldersScreen> {
  final List<String> _selectedFolders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4057),
        title: const Text('Select Folders', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onFoldersSelected(_selectedFolders);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: FolderManager().folders.length,
        itemBuilder: (context, index) {
          String folderName = FolderManager().folders[index];
          bool isSelected = _selectedFolders.contains(folderName);
          return ListTile(
            title: Text(folderName, style: const TextStyle(color: Colors.white)),
            trailing: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
            tileColor: isSelected ? const Color(0xFF4993FA) : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFolders.remove(folderName);
                } else {
                  _selectedFolders.add(folderName);
                }
              });
            },
          );
        },
      ),
    );
  }
}
