import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateSetScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSet;

  const CreateSetScreen({super.key, this.initialSet});

  @override
  _CreateSetScreenState createState() => _CreateSetScreenState();
}

class _CreateSetScreenState extends State<CreateSetScreen> {
  final TextEditingController _titleController =
      TextEditingController(); // Controls the text for the title input field.
  final TextEditingController _descriptionController =
      TextEditingController(); // Controls the text for the description input field.
  List<Map<String, dynamic>> terms =
      []; // List to store each term and its details.
  late ScrollController
      _scrollController; // Controller for scrolling the list of terms.

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Initialize the screen with data if editing an existing set.
    if (widget.initialSet != null) {
      _titleController.text = widget.initialSet!['title'];
      _descriptionController.text = widget.initialSet!['description'] ?? '';
      // Map each term from the initial set into a format suitable for editing.
      terms =
          List<Map<String, dynamic>>.from(widget.initialSet!['terms']).map((t) {
        return {
          'term': t['term'],
          'definition': t['definition'],
          'termController': TextEditingController(text: t['term']),
          'defController': TextEditingController(text: t['definition']),
          'termFocus': FocusNode(),
          'defFocus': FocusNode(),
        };
      }).toList();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dispose all controllers and focus nodes to free up resources.
    for (var term in terms) {
      term['termFocus'].dispose();
      term['defFocus'].dispose();
      term['termController'].dispose();
      term['defController'].dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

// Check if any term or definition field is left empty.
  bool _checkEmptyFields() {
    for (var term in terms) {
      if (term['termController'].text.isEmpty ||
          term['defController'].text.isEmpty) {
        return true;
      }
    }
    return false;
  }

  void _saveSet() async {
    // Validate that all fields are filled before saving.
    if (_titleController.text.isEmpty || terms.isEmpty || _checkEmptyFields()) {
      if (!mounted) return;
      _showAlertDialog(
          'You must fill in the title and all term-definition pairs to save your set.');
      return;
    }

// Prepare the set for saving or updating.
    Map<String, dynamic> set = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'terms': terms
          .map((t) => {
                'term': t['termController'].text,
                'definition': t['defController'].text
              })
          .toList(),
    };

// Save or update the set in shared preferences.
    final prefs = await SharedPreferences.getInstance();
    List<String> setsJson = prefs.getStringList('sets') ?? [];
    List<Map<String, dynamic>> sets =
        setsJson.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

    int indexToUpdate =
        sets.indexWhere((s) => s['title'] == widget.initialSet?['title']);
    if (indexToUpdate != -1) {
      sets[indexToUpdate] = set;
    } else {
      sets.add(set);
    }

    await prefs.setStringList('sets', sets.map((s) => jsonEncode(s)).toList());
    if (!mounted) return;
    Navigator.pop(context);
  }

// Show an alert dialog if fields are missing or empty.
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content:
              Text(message, style: const TextStyle(color: Color(0xFFC3D1DB))),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                      color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

// Add a new term & definition to the list.
  void _addTermDefinition() {
    var newTerm = {
      'term': '',
      'definition': '',
      'termController': TextEditingController(),
      'defController': TextEditingController(),
      'termFocus': FocusNode(),
      'defFocus': FocusNode(),
    };
    setState(() {
      terms.add(newTerm);
      _scrollToCurrent(); // Automatically scroll to the new term.
    });
  }

// Remove a term from the list and show confirmation.
  void _removeTerm(int index) {
    setState(() {
      terms.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Term deleted")));
  }

  // Scroll to the end of the list to view the newly added term.
  void _scrollToCurrent() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      }
    });
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius:
            BorderRadius.circular(8), // Match the border radius of the card
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4057),
        title: Text(widget.initialSet == null ? 'Create Set' : 'Edit Set',
            style: const TextStyle(color: Color(0xFFC3D1DB))),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSet, // Save the set when the check icon is tapped.
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                cursorColor: const Color(0xFF59A6BF),
                style: const TextStyle(color: Color(0xFFC3D1DB)),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Subject, chapter, unit',
                  hintStyle: TextStyle(color: Color(0xFF2B4057)),
                  labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                cursorColor: const Color(0xFF59A6BF),
                style: const TextStyle(color: Color(0xFFC3D1DB)),
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              ...terms.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> term = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Dismissible(
                    key: Key(
                        '${term['term']} $index'), // Unique key for each dismissible widget.
                    background: _buildDismissBackground(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeTerm(index),
                    child: Card(
                      color: const Color(0xFF2B4057),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: term['termController'],
                              focusNode: term['termFocus'],
                              cursorColor: const Color(0xFF59A6BF),
                              style: const TextStyle(color: Color(0xFFC3D1DB)),
                              decoration: const InputDecoration(
                                labelText: 'Term',
                                labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: term['defController'],
                              focusNode: term['defFocus'],
                              cursorColor: const Color(0xFF59A6BF),
                              style: const TextStyle(color: Color(0xFFC3D1DB)),
                              decoration: const InputDecoration(
                                labelText: 'Definition',
                                labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTermDefinition,
        backgroundColor: const Color(0xFF59A6BF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
