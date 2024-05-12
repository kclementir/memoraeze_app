import 'package:flutter/material.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> terms;

  const FlashcardScreen({Key? key, required this.terms}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.terms.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentTerm = widget.terms[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Flashcards')),
      body: GestureDetector(
        onTap: _nextCard,
        child: Center(
          child: Card(
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(currentTerm['term'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text(currentTerm['definition'], style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
