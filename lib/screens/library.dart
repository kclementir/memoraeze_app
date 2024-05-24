import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/screens/create.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';
import 'package:memoraeze_flashcard_app/models/flashcard.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';
import 'package:memoraeze_flashcard_app/views/folder_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class LibraryScreen extends StatefulWidget {
  final int tabIndex;

  const LibraryScreen({super.key, required this.tabIndex});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _studySets = [];
  final FolderManager _folderManager = FolderManager();

  List<Map<String, dynamic>> get folders => _folderManager.folderDetails;

  static const Color appBarColor = Color(0xFF2B4057);
  static const Color primaryTextColor = Color(0xFFC3D1DB);
  static const Color highlightColor = Color(0xFF59A6BF);
  static const Color unselectedLabelColor = Color(0xFF3C4D60);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.tabIndex);
    _loadStudySets();
    _loadFolders();
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
          return <String, dynamic>{};
        }
      }).toList();
    });
  }

  void _loadFolders() async {
    await _folderManager.loadFoldersFromPrefs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(color: primaryTextColor)),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: primaryTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: primaryTextColor),
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
          _buildStudySetsView(),
          _buildFoldersView(),
        ],
      ),
    );
  }

  void _handleAddAction() {
    if (_tabController.index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateSetScreen()));
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          title: const Text('Create folder', style: TextStyle(color: primaryTextColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('Folder name', onChanged: (value) => newFolderName = value),
              const SizedBox(height: 20),
              _buildTextField('Description (optional)', onChanged: (value) => newFolderDescription = value),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK', style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                if (newFolderName.isNotEmpty) {
                  setState(() {
                    _folderManager.addFolder(newFolderName, description: newFolderDescription);
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

  Widget _buildTextField(String hintText, {required void Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: primaryTextColor.withOpacity(0.6)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: highlightColor)),
      ),
      style: const TextStyle(color: primaryTextColor),
      cursorColor: highlightColor,
    );
  }

  Widget _buildStudySetsView() {
    return ListView.builder(
      itemCount: _studySets.length,
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () {
            List<FlashCard> flashCards = _studySets[index]['terms'].map<FlashCard>((term) {
              return FlashCard(
                question: term['term'],
                answer: term['definition'],
                options: term['options'] ?? [],
                topic: _studySets[index]['title'],
              );
            }).toList();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewCard(
                topicName: _studySets[index]['title'],
                typeOfTopic: 'Study Set',
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
    );
  }

  Widget _buildFoldersView() {
    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => FolderDetailsScreen(folderName: folders[index]['name']!),
            ));
          },
          child: FolderBox(
            folderName: folders[index]['name']!,
            description: folders[index]['description'],
            descriptionStyle: const TextStyle(color: primaryTextColor, fontSize: 12),
            showIcon: true,
          ),
        );
      },
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

  const FolderBox({super.key, required this.folderName, this.description, this.descriptionStyle, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _LibraryScreenState.appBarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: showIcon ? const Icon(Icons.folder_outlined, color: _LibraryScreenState.primaryTextColor) : null,
        title: Text(folderName, style: const TextStyle(color: _LibraryScreenState.primaryTextColor)),
        subtitle: description != null ? Text(description!, style: descriptionStyle ?? const TextStyle(color: _LibraryScreenState.primaryTextColor)) : null,
      ),
    );
  }
}
