import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/models/flashcard.dart';
import 'package:memoraeze_flashcard_app/screens/create.dart';
import 'package:memoraeze_flashcard_app/views/select_folders_screen.dart';
import 'package:memoraeze_flashcard_app/widgets/flash_card_widget.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:memoraeze_flashcard_app/classes/folder_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class NewCard extends StatefulWidget {
  final String topicName;
  final String typeOfTopic;
  final List<FlashCard> flashCards;

  const NewCard({
    super.key,
    required this.topicName,
    required this.flashCards,
    required this.typeOfTopic,
  });

  @override
  NewCardState createState() => NewCardState();
}

class NewCardState extends State<NewCard> {
  late AppinioSwiperController _controller;
  late List<FlashCard> _shuffledFlashCards;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _controller = AppinioSwiperController();
    _shuffledFlashCards = List.from(widget.flashCards);
  }

  void _shuffleFlashCards() {
    setState(() {
      _shuffledFlashCards.shuffle(Random());
      _controller = AppinioSwiperController(); // Reset controller to start over with shuffled cards
    });
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {},
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF102F50),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Icon(Icons.drag_handle_rounded, size: 36, color: Colors.white),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder, color: Colors.white),
                    title: const Text('Add to Folder', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      _navigateToSelectFoldersScreen(context); // Show select folders screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.white),
                    title: const Text('Edit Set', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the settings modal
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CreateSetScreen(
                          initialSet: {
                            'title': widget.topicName,
                            'description': widget.typeOfTopic, // Adjust based on actual data structure
                            'terms': widget.flashCards.map((card) => {
                              'term': card.question,
                              'definition': card.answer,
                              // include other fields if necessary
                            }).toList(),
                          },
                        ),
                      ));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Color.fromARGB(255, 172, 70, 70)),
                    title: const Text('Delete Set', style: TextStyle(color: Color.fromARGB(255, 172, 70, 70))),
                    onTap: () {
                      Navigator.of(context).pop(); // Optionally close the bottom sheet immediately
                      _showDeleteConfirmationDialog(); // Show confirmation dialog
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToSelectFoldersScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SelectFoldersScreen(
        onFoldersSelected: (selectedFolders) {
          for (var folder in selectedFolders) {
            FolderManager().addSetToFolder(folder, {
              'title': widget.topicName,
              'description': widget.typeOfTopic,
              'terms': widget.flashCards.map((card) => {
                'term': card.question,
                'definition': card.answer,
              }).toList(),
            });
          }
          // Show confirmation message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to ${selectedFolders.join(', ')} successfully!'),
            ),
          );
        },
      ),
    ));
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this set completely?',
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
              onPressed: () async {
                await _deleteSet();
                Navigator.of(context).pop(); // Dismiss the dialog after confirming deletion
                Navigator.of(context).pop(); // Close the settings modal too
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSet() async {
    try {
      // Remove the set from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> setsJson = prefs.getStringList('sets') ?? [];
      List<Map<String, dynamic>> sets = setsJson.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

      sets.removeWhere((s) => s['title'] == widget.topicName);
      await prefs.setStringList('sets', sets.map((s) => jsonEncode(s)).toList());

      // Remove the set from Firebase Realtime Database
      Query query = _database.child('sets').orderByChild('title').equalTo(widget.topicName);
      DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        Map<String, dynamic> setMap = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        setMap.forEach((key, value) async {
          await _database.child('sets').child(key).remove();
        });
      }

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set deleted successfully!')),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting set: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF102F50);
    const Color cardColor = Color(0xFF4993FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.clear, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppinioSwiper(
                controller: _controller,
                cardCount: _shuffledFlashCards.length,
                cardBuilder: (context, index) {
                  var card = _shuffledFlashCards[index];
                  return FlipCardsWidget(
                    bgColor: cardColor,
                    cardsLength: _shuffledFlashCards.length,
                    currentIndex: index + 1,
                    answer: card.answer,
                    question: card.question,
                    currentTopic: widget.topicName,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(cardColor),
                  ),
                  onPressed: _shuffleFlashCards,
                  child: const Text("Reorder Cards", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
