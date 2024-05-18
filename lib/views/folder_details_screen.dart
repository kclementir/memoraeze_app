import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';
import 'package:memoraeze_flashcard_app/models/flashcard.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';
import 'package:memoraeze_flashcard_app/views/sets_select_screen.dart';

class FolderDetailsScreen extends StatefulWidget {
  final String folderName;

  const FolderDetailsScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  _FolderDetailsScreenState createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final folderDetails = FolderManager().getSetsInFolder(widget.folderName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4057),
        title: Text(widget.folderName, style: const TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Edit':
                  _showEditFolderDialog(context);
                  break;
                case 'Add Sets':
                  _navigateToAddSets(context);
                  break;
                case 'Delete':
                  _showDeleteConfirmationDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Edit', 'Add Sets', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: folderDetails.length,
        itemBuilder: (context, index) {
          final set = folderDetails[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: const Color(0xFF102F50),
            child: ListTile(
              title: Text(set['title'], style: const TextStyle(color: Colors.white)),
              subtitle: Text('${set['terms'].length} terms', style: const TextStyle(color: Colors.white)),
              onTap: () {
                List<FlashCard> flashCards = set['terms'].map<FlashCard>((term) {
                  return FlashCard(
                    question: term['term'],
                    answer: term['definition'],
                    options: term['options'] ?? [],
                    topic: set['title'],
                  );
                }).toList();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewCard(
                    topicName: set['title'],
                    typeOfTopic: 'Folder Set',
                    flashCards: flashCards,
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context) {
    String newFolderName = widget.folderName;
    String? newFolderDescription;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          title: const Text('Edit folder', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('Folder name', initialValue: newFolderName,
                  onChanged: (value) => newFolderName = value),
              const SizedBox(height: 20),
              _buildTextField('Description (optional)',
                  initialValue: newFolderDescription,
                  onChanged: (value) => newFolderDescription = value),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL',
                  style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('SAVE',
                  style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  FolderManager().updateFolder(widget.folderName, newFolderName,
                      description: newFolderDescription);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String hintText, {required void Function(String) onChanged, String? initialValue}) {
    return TextField(
      onChanged: onChanged,
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFC3D1DB)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF59A6BF))),
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFF59A6BF),
    );
  }

  void _navigateToAddSets(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddSetsScreen(folderName: widget.folderName),
    ));
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this folder permanently? The sets will not be deleted.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Color.fromARGB(255, 172, 70, 70), fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  FolderManager().removeFolder(widget.folderName);
                });
                Navigator.of(context).pop(); // Dismiss the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }
}
