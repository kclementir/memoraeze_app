import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateSetScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSet;

  const CreateSetScreen({super.key, this.initialSet});

  @override
  _CreateSetScreenState createState() => _CreateSetScreenState();
}

class _CreateSetScreenState extends State<CreateSetScreen> {
  final TextEditingController _titleController = TextEditingController(); // Controls the text for the title input field.
  final TextEditingController _descriptionController = TextEditingController(); // Controls the text for the description input field.
  List<Map<String, dynamic>> terms = []; // List to store each term and its details.
  late ScrollController _scrollController; // Controller for scrolling the list of terms.
  late DatabaseReference _database; // Firebase database reference

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _scrollController = ScrollController();
    if (widget.initialSet != null) {
      _initializeSetForEditing();
    }
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
    _database = FirebaseDatabase.instance.reference();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _disposeControllers();
    super.dispose();
  }

  // Initialize the set for editing if it's an existing set
  void _initializeSetForEditing() {
    _titleController.text = widget.initialSet!['title'];
    _descriptionController.text = widget.initialSet!['description'] ?? '';
    terms = List<Map<String, dynamic>>.from(widget.initialSet!['terms']).map((t) {
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

  // Dispose all controllers and focus nodes to free up resources
  void _disposeControllers() {
    for (var term in terms) {
      term['termFocus'].dispose();
      term['defFocus'].dispose();
      term['termController'].dispose();
      term['defController'].dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();
  }

  // Check if any term or definition field is left empty
  bool _checkEmptyFields() {
    for (var term in terms) {
      if (term['termController'].text.isEmpty || term['defController'].text.isEmpty) {
        return true;
      }
    }
    return false;
  }

  // Save the set to shared preferences and Firebase
  void _saveSet() async {
    if (_titleController.text.isEmpty || terms.isEmpty || _checkEmptyFields()) {
      if (!mounted) return;
      _showAlertDialog('You must fill in the title and all term-definition pairs to save your set.');
      return;
    }

    Map<String, dynamic> set = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'terms': terms.map((t) => {
        'term': t['termController'].text,
        'definition': t['defController'].text
      }).toList(),
    };

    final prefs = await SharedPreferences.getInstance();
    List<String> setsJson = prefs.getStringList('sets') ?? [];
    List<Map<String, dynamic>> sets = setsJson.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

    int indexToUpdate = sets.indexWhere((s) => s['title'] == widget.initialSet?['title']);
    if (indexToUpdate != -1) {
      sets[indexToUpdate] = set;
    } else {
      sets.add(set);
    }

    await prefs.setStringList('sets', sets.map((s) => jsonEncode(s)).toList());

    // Save the set to Firebase Realtime Database
    if (widget.initialSet == null) {
      _database.child('sets').push().set(set);
    } else {
      if (widget.initialSet!.containsKey('key')) {
        String key = widget.initialSet!['key'];
        _database.child('sets').child(key).set(set);
      } else {
        _database.child('sets').push().set(set);
      }
    }

    if (!mounted) return;
    _showSuccessDialog('Saved successfully');
  }

  // Show an alert dialog if fields are missing or empty
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Text(message, style: const TextStyle(color: Color(0xFFC3D1DB))),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Show a success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Text(message, style: const TextStyle(color: Color(0xFFC3D1DB))),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Navigate back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  // Add a new term and definition to the list
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
      _scrollToCurrent();
    });
  }

  // Remove a term from the list and show confirmation
  void _removeTerm(int index) {
    setState(() {
      terms.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Term deleted")));
  }

  // Scroll to the end of the list to view the newly added term
  void _scrollToCurrent() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      }
    });
  }

  // Build background for dismissible term
  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
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
        title: Text(widget.initialSet == null ? 'Create Set' : 'Edit Set', style: const TextStyle(color: Color(0xFFC3D1DB))),
        iconTheme: const IconThemeData(color: Color(0xFFC3D1DB)), // Set the color of the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFC3D1DB)), // Set the color of the check icon
            onPressed: _saveSet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTitleInput(),
              const SizedBox(height: 20),
              _buildDescriptionInput(),
              const SizedBox(height: 20),
              ...terms.asMap().entries.map((entry) => _buildTermCard(entry.key, entry.value)).toList(),
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

  // Build the title input field
  Widget _buildTitleInput() {
    return TextField(
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
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  // Build the description input field
  Widget _buildDescriptionInput() {
    return TextField(
      controller: _descriptionController,
      cursorColor: const Color(0xFF59A6BF),
      style: const TextStyle(color: Color(0xFFC3D1DB)),
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  // Build a card for each term
  Widget _buildTermCard(int index, Map<String, dynamic> term) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Dismissible(
        key: Key('${term['term']} $index'),
        background: _buildDismissBackground(),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _removeTerm(index),
        child: Card(
          color: const Color(0xFF2B4057),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildTermInput(term),
                const SizedBox(height: 10),
                _buildDefinitionInput(term),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the term input field
  Widget _buildTermInput(Map<String, dynamic> term) {
    return TextField(
      controller: term['termController'],
      focusNode: term['termFocus'],
      cursorColor: const Color(0xFF59A6BF),
      style: const TextStyle(color: Color(0xFFC3D1DB)),
      decoration: const InputDecoration(
        labelText: 'Term',
        labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  // Build the definition input field
  Widget _buildDefinitionInput(Map<String, dynamic> term) {
    return TextField(
      controller: term['defController'],
      focusNode: term['defFocus'],
      cursorColor: const Color(0xFF59A6BF),
      style: const TextStyle(color: Color(0xFFC3D1DB)),
      decoration: const InputDecoration(
        labelText: 'Definition',
        labelStyle: TextStyle(color: Color(0xFFC3D1DB)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
