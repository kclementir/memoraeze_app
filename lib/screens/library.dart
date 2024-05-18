import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/screens/create.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';
import 'package:memoraeze_flashcard_app/models/flashcard.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _studySets = [];

  List<Map<String, String?>> get folders => FolderManager().folderDetails;

  static const Color appBarColor = Color(0xFF2B4057);
  static const Color primaryTextColor = Color(0xFFC3D1DB);
  static const Color highlightColor = Color(0xFF59A6BF);
  static const Color unselectedLabelColor = Color(0xFF3C4D60);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStudySets();
  }

  void _loadStudySets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> setsJson = prefs.getStringList('sets') ?? [];
    setState(() {
      _studySets = setsJson.map((s) {
        var decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          logger.w("Data is not in the expected format: $decoded");
          return <String, dynamic>{}; // Return an empty map to maintain the type integrity
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Library',
              style: TextStyle(
                  color: primaryTextColor, fontWeight: FontWeight.bold)),
          backgroundColor: appBarColor,
          iconTheme: const IconThemeData(color: primaryTextColor),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _handleAddAction,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: primaryTextColor,
            unselectedLabelColor: unselectedLabelColor,
            indicator: const BoxDecoration(
              border: Border(bottom: BorderSide(color: highlightColor, width: 4.5)),
            ),
            tabs: const [
              Tab(text: 'Study Sets'),
              Tab(text: 'Folders'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // First Tab: Study Sets
            ListView.builder(
              itemCount: _studySets.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () {
                    List<FlashCard> flashCards = _studySets[index]['terms'].map<FlashCard>((term) {
                      return FlashCard(
                        question: term['term'],
                        answer: term['definition'],
                        options: term['options'] ?? [],
                        topic: _studySets[index]['title'], // Assuming 'title' is part of your study set structure
                      );
                    }).toList();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NewCard(
                        topicName: _studySets[index]['title'],
                        typeOfTopic: 'Study Set', // This can be dynamic based on your app's context
                        flashCards: flashCards,
                      ),
                    ));
                  },
                  child: FolderBox(
                    folderName: _studySets[index]['title'],
                    description: '${_studySets[index]['terms'].length} terms',
                    descriptionStyle: const TextStyle(color: primaryTextColor, fontSize: 12),
                    showIcon: false,
                  ),
                );
              },
            ),

            // Second Tab: Folders
            ListView.builder(
              itemCount: folders.length,
              itemBuilder: (_, index) => FolderBox(
                folderName: folders[index]['name']!,
                description: folders[index]['description'],
                descriptionStyle: const TextStyle(color: primaryTextColor, fontSize: 12),
                showIcon: true,
              ),
            ),
          ],
        ));
  }

  void _handleAddAction() {
    if (_tabController.index == 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateSetScreen()));
    } else {
      _showFolderDialog();
    }
  }

  void _showFolderDialog() {
    String newFolderName = '';
    String? newFolderDescription;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appBarColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          title: const Text('Create folder',
              style: TextStyle(color: primaryTextColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('Folder name',
                  onChanged: (value) => newFolderName = value),
              const SizedBox(height: 20),
              _buildTextField('Description (optional)',
                  onChanged: (value) => newFolderDescription = value),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL',
                  style: TextStyle(
                      color: highlightColor, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                      color: highlightColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                if (newFolderName.isNotEmpty) {
                  FolderManager().addFolder(newFolderName, description: newFolderDescription);
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the UI to show the new folder
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String hintText,
      {required void Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: primaryTextColor.withOpacity(0.6)),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: highlightColor)),
      ),
      style: const TextStyle(color: primaryTextColor),
      cursorColor: highlightColor,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class FolderBox extends StatelessWidget {
  final String folderName;
  final String? description;
  final TextStyle? descriptionStyle;
  final bool showIcon;

  const FolderBox(
      {super.key,
      required this.folderName,
      this.description,
      this.descriptionStyle,
      this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _LibraryScreenState.appBarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: showIcon
            ? const Icon(Icons.folder_outlined,
                color: _LibraryScreenState.primaryTextColor)
            : null,
        title: Text(
          folderName,
          style: const TextStyle(color: _LibraryScreenState.primaryTextColor),
        ),
        subtitle: description != null
            ? Text(
                description!,
                style: descriptionStyle ??
                    const TextStyle(
                        color: _LibraryScreenState.primaryTextColor),
              )
            : null,
      ),
    );
  }
}
