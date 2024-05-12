import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateSetScreen extends StatefulWidget {
  const CreateSetScreen({super.key});

  @override
  _CreateSetScreenState createState() => _CreateSetScreenState();
}

class _CreateSetScreenState extends State<CreateSetScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> terms = [];
  late ScrollController _scrollController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var term in terms) {
      term['termFocus'].dispose();
      term['defFocus'].dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveSet() async {
    if (_titleController.text.isEmpty || terms.isEmpty) {
      _showAlertDialog();
      return;
    }

    Map<String, dynamic> set = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'terms': terms.map((t) => {'term': t['term'], 'definition': t['definition']}).toList(),
    };

    final prefs = await SharedPreferences.getInstance();
    List<String> setsJson = prefs.getStringList('sets') ?? [];
    setsJson.add(jsonEncode(set));
    await prefs.setStringList('sets', setsJson);

    Navigator.pop(context);
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: const Text(
            'You must fill in the title and add at least one term-definition pair to save your set.',
            style: TextStyle(color: Color(0xFFC3D1DB)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTermDefinition() {
    terms.add({
      'term': '',
      'definition': '',
      'termFocus': FocusNode(),
      'defFocus': FocusNode()
    });
    setState(() {
      currentIndex = terms.length - 1;
    });
    _scrollToCurrent();
  }

  void _scrollToCurrent() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateFocus(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4057),
        title: Text(
          terms.isEmpty ? 'Create Set' : ' ${currentIndex + 1}/${terms.length}',
          style: const TextStyle(color: Color(0xFFC3D1DB)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3D1DB)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
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
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
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
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...terms.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> term = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Card(
                    color: const Color(0xFF2B4057),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            focusNode: term['termFocus'],
                            onTap: () => _updateFocus(index),
                            onChanged: (value) {
                              setState(() {
                                term['term'] = value;
                              });
                            },
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
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            focusNode: term['defFocus'],
                            onTap: () => _updateFocus(index),
                            onChanged: (value) {
                              setState(() {
                                term['definition'] = value;
                              });
                            },
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
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
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
