import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/models/flashcard.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';
import 'package:memoraeze_flashcard_app/views/folder_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> studySets = [];
  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();

    // Load notes
    List<String>? notesJson = prefs.getStringList('notes');
    if (notesJson != null) {
      setState(() {
        notes = notesJson.map((n) => jsonDecode(n) as Map<String, dynamic>).toList();
      });
    } else {
      print("No notes found.");
    }

    // Load study sets
    List<String>? setsJson = prefs.getStringList('sets');
    if (setsJson != null) {
      try {
        setState(() {
          studySets = setsJson.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
        });
      } catch (e) {
        print("Error parsing study sets: $e");
      }
    } else {
      print("No study sets found.");
    }

    // Load folders
    List<String>? foldersJson = prefs.getStringList('folders');
    if (foldersJson != null) {
      try {
        setState(() {
          folders = foldersJson.map((f) => jsonDecode(f) as Map<String, dynamic>).toList();
        });
      } catch (e) {
        print("Error parsing folders: $e");
      }
    } else {
      print("No folders found.");
    }
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items, String viewAllRoute, {required int arguments}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Color(0xFFC3D1DB),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, viewAllRoute, arguments: arguments);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF59A6BF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return GestureDetector(
                  onTap: () {
                    if (title == 'Study Sets') {
                      List<FlashCard> flashCards = (item['terms'] as List).map<FlashCard>((term) {
                        return FlashCard(
                          question: term['term'],
                          answer: term['definition'],
                          options: term['options'] ?? [],
                          topic: item['title'],
                        );
                      }).toList();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NewCard(
                          topicName: item['title'],
                          typeOfTopic: 'Study Set',
                          flashCards: flashCards,
                        ),
                      ));
                    } else if (title == 'Notes') {
                      // Navigate to the note details screen if available
                      // For now, we'll just print the note details
                      print("Note details: ${item['title']}, ${item['content']}");
                    } else if (title == 'Folders') {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FolderDetailsScreen(folderName: item['name']),
                      ));
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FolderBox(
                      folderName: item['title'] ?? item['name'],
                      description: item['description'],
                      descriptionStyle: const TextStyle(color: Color(0xFFC3D1DB)),
                      showIcon: false,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(
          color: Color(0xFF2B4057),
          thickness: 1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102F50),
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Color(0xFFC3D1DB))),
        backgroundColor: const Color(0xFF2B4057),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildSection('Notes', notes, '/allNotes', arguments: 2),
          ),
          Expanded(
            child: _buildSection('Study Sets', studySets, '/library', arguments: 0),
          ),
          Expanded(
            child: _buildSection('Folders', folders, '/library', arguments: 1),
          ),
        ],
      ),
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
