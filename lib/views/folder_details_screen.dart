import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';
import 'package:memoraeze_flashcard_app/models/flashcard.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';

class FolderDetailsScreen extends StatelessWidget {
  final String folderName;

  const FolderDetailsScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final folderDetails = FolderManager().getSetsInFolder(folderName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4057),
        title: Text(folderName, style: const TextStyle(color: Colors.white)),
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
}
