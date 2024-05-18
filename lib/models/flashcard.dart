import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';

// StatefulWidget for displaying flashcards
class FlashcardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> terms; // List of terms and definitions
  final String title; // Title of the flashcard set

  const FlashcardScreen({super.key, required this.terms, required this.title});

  @override
  FlashcardScreenState createState() =>
      FlashcardScreenState();
}

// State class for FlashcardScreen
class FlashcardScreenState extends State<FlashcardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Display the title of the flashcard set
      ),
      body: ListView.builder(
        itemCount: widget.terms.length, // Number of terms
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.terms[index]['term']), // Display term
            subtitle:
                Text(widget.terms[index]['definition']), // Display definition
            onTap: () {
              // Create a List<FlashCard> from terms
              List<FlashCard> flashCards = widget.terms.map((term) {
                return FlashCard(
                  question: term['term'],
                  answer: term['definition'],
                  options: term['options'] ?? [],
                  topic: widget.title, // Use the title of the flashcard set
                );
              }).toList();

              // Navigate to NewCard screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewCard(
                  topicName: widget.title,
                  typeOfTopic: 'Terms and Definitions',
                  flashCards: flashCards,
                ),
              ));
            },
          );
        },
      ),
    );
  }
}

// Model class for FlashCard
class FlashCard {
  String question; // Question or term
  String answer; // Answer or definition
  List<String> options; // Options for the flashcard
  String? topic; // Topic of the flashcard set

  FlashCard(
      {required this.question,
      required this.answer,
      this.options = const [],
      this.topic});

  // Convert FlashCard to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'options': options,
    };
  }
}
