import 'package:flutter/material.dart';
import 'package:memoraeze_flashcard_app/views/flashcard_screen.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> terms;
  final String title;

  const FlashcardScreen({Key? key, required this.terms, required this.title}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: widget.terms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.terms[index]['term']),
            subtitle: Text(widget.terms[index]['definition']),
            onTap: () {
              // Create a List<FlashCard> from terms
              List<FlashCard> flashCards = widget.terms.map((term) {
                return FlashCard(
                  question: term['term'],
                  answer: term['definition'],
                  options: term['options'] ?? [], topic: null,
                );
              }).toList();

              // Navigate to NewCard
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


class FlashCard {
  String question;
  String answer;
  List<String> options;

  FlashCard({required this.question, required this.answer, this.options = const [], required topic});

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'options': options,
    };
  }
}
