import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';

class SelectFoldersScreen extends StatefulWidget {
  final Function(List<String>) onFoldersSelected;

  const SelectFoldersScreen({super.key, required this.onFoldersSelected});

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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              widget.onFoldersSelected(_selectedFolders);
              Navigator.of(context).pop();
              _showSnackBar(context, 'Folders selected: ${_selectedFolders.join(', ')}');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: FolderManager().folders.length,
        itemBuilder: (context, index) {
          String folderName = FolderManager().folders[index];
          bool isSelected = _selectedFolders.contains(folderName);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFolders.remove(folderName);
                } else {
                  _selectedFolders.add(folderName);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4993FA) : const Color(0xFF2B4057),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(
                  folderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF59A6BF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
