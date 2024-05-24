import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

// Main function to run the NotesApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  // Define colors for the app
  static const Color appBarColor = Color(0xFF2B4057);
  static const Color primaryTextColor = Color(0xFFC3D1DB);
  static const Color highlightColor = Color(0xFF59A6BF);
  static const Color unselectedLabelColor = Color(0xFF3C4D60);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primaryColor: appBarColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: highlightColor,
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: primaryTextColor),
          bodyText2: TextStyle(color: primaryTextColor),
        ),
      ),
      home: const NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> _notes = [];
  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('notes');

  @override
  void initState() {
    super.initState();
    _filteredNotes = _notes;
    _searchController.addListener(_filterNotes);
    _databaseReference.onChildAdded.listen(_addNoteFromDatabase);
    _databaseReference.onChildChanged.listen(_updateNoteInList);
    _databaseReference.onChildRemoved.listen(_removeNoteFromList);
  }

  // Filter notes based on search query
  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Add a new note
  void _addNote() async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => const AddNoteScreen(),
      ),
    );

    if (result != null) {
      _databaseReference.push().set(result.toJson());
    }
  }

  // Edit an existing note
  void _editNote(Note note, int index) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => ViewNoteScreen(note: note),
      ),
    );

    if (result != null) {
      _databaseReference.child(note.id).set(result.toJson());
    }
  }

  // Confirm deletion of a note
  void _deleteNoteWithConfirmation(Note note, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: NotesApp.appBarColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          title: const Text('Delete Note', style: TextStyle(color: NotesApp.primaryTextColor)),
          content: const Text('Are you sure you want to delete this note?', style: TextStyle(color: NotesApp.primaryTextColor)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: NotesApp.highlightColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Color.fromARGB(255, 172, 70, 70), fontWeight: FontWeight.bold)),
              onPressed: () {
                _databaseReference.child(note.id).remove();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Build background for dismissible note
  Widget _buildDismissBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 36),
    );
  }

  // Add note from database
  void _addNoteFromDatabase(DatabaseEvent event) {
    setState(() {
      final note = Note.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
      note.id = event.snapshot.key!;
      _notes.add(note);
      _filteredNotes = _notes;
    });
  }

  // Update note in list
  void _updateNoteInList(DatabaseEvent event) {
    final updatedNote = Note.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    updatedNote.id = event.snapshot.key!;

    setState(() {
      final index = _notes.indexWhere((note) => note.id == updatedNote.id);
      _notes[index] = updatedNote;
      _filteredNotes = _notes;
    });
  }

  // Remove note from list
  void _removeNoteFromList(DatabaseEvent event) {
    setState(() {
      final note = _notes.firstWhere((note) => note.id == event.snapshot.key);
      _notes.remove(note);
      _filteredNotes = _notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All notes', style: TextStyle(color: NotesApp.primaryTextColor)),
        backgroundColor: NotesApp.appBarColor,
        iconTheme: const IconThemeData(color: NotesApp.primaryTextColor),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildNotesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: NotesApp.highlightColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search notes',
          hintStyle: TextStyle(color: NotesApp.primaryTextColor),
          prefixIcon: Icon(Icons.search, color: NotesApp.primaryTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: NotesApp.primaryTextColor),
          ),
        ),
        style: const TextStyle(color: NotesApp.primaryTextColor),
        cursorColor: NotesApp.highlightColor,
      ),
    );
  }

  // Build notes list
  Widget _buildNotesList() {
    return Expanded(
      child: _filteredNotes.isEmpty
          ? const Center(
              child: Text('No notes yet. Tap + to add a new note.', style: TextStyle(color: NotesApp.primaryTextColor)),
            )
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteNoteWithConfirmation(note, index);
                  },
                  background: _buildDismissBackground(),
                  child: _buildNoteTile(note, index),
                );
              },
            ),
    );
  }

  // Build a single note tile
  Widget _buildNoteTile(Note note, int index) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: NotesApp.appBarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(note.title, style: const TextStyle(color: NotesApp.primaryTextColor)),
        subtitle: Text(note.dateCreated, style: const TextStyle(color: NotesApp.primaryTextColor)),
        tileColor: index % 2 == 0 ? Colors.white : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        onTap: () => _editNote(note, index),
      ),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _undoHistory = [];
  final List<String> _redoHistory = [];

  // Save the note
  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      final dateCreated = DateFormat('dd/MM').format(DateTime.now());
      final note = Note(
        title: title,
        content: content,
        dateCreated: dateCreated,
      );
      Navigator.of(context).pop(note);
    }
  }

  // Undo the last change
  void _undo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _redoHistory.add(_contentController.text);
        _contentController.text = _undoHistory.removeLast();
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      });
    }
  }

  // Redo the last undone change
  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        _undoHistory.add(_contentController.text);
        _contentController.text = _redoHistory.removeLast();
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NotesApp.primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit note', style: TextStyle(color: NotesApp.primaryTextColor)),
        backgroundColor: NotesApp.appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: NotesApp.primaryTextColor),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: NotesApp.primaryTextColor),
            onPressed: _redo,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: NotesApp.primaryTextColor),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNoteDate(),
          _buildTitleInput(),
          _buildContentInput(),
        ],
      ),
    );
  }

  // Build note date display
  Widget _buildNoteDate() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()),
            style: const TextStyle(color: NotesApp.primaryTextColor),
          ),
        ],
      ),
    );
  }

  // Build title input field
  Widget _buildTitleInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _titleController,
        maxLines: 1,
        decoration: const InputDecoration(
          hintText: 'Enter title here',
          border: InputBorder.none,
          hintStyle: TextStyle(fontWeight: FontWeight.bold, color: NotesApp.primaryTextColor),
        ),
        style: const TextStyle(fontWeight: FontWeight.bold, color: NotesApp.primaryTextColor),
        cursorColor: NotesApp.highlightColor,
      ),
    );
  }

  // Build content input field
  Widget _buildContentInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter your note here',
            border: InputBorder.none,
            hintStyle: TextStyle(color: NotesApp.primaryTextColor),
          ),
          style: const TextStyle(color: NotesApp.primaryTextColor),
          cursorColor: NotesApp.highlightColor,
          onChanged: (text) {
            _undoHistory.add(text);
          },
        ),
      ),
    );
  }
}

class ViewNoteScreen extends StatefulWidget {
  final Note note;
  const ViewNoteScreen({super.key, required this.note});

  @override
  _ViewNoteScreenState createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _controller;
  bool _isEditing = false;
  final List<String> _undoHistory = [];
  final List<String> _redoHistory = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _controller = _contentController;
  }

  // Save the note
  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      final updatedNote = Note(
        title: title,
        content: content,
        dateCreated: widget.note.dateCreated,
      );
      Navigator.of(context).pop(updatedNote);
    }
  }

  // Toggle edit mode
  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Undo the last change
  void _undo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _redoHistory.add(_controller.text);
        _controller.text = _undoHistory.removeLast();
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }
  }

  // Redo the last undone change
  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        _undoHistory.add(_controller.text);
        _controller.text = _redoHistory.removeLast();
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NotesApp.primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('View note', style: TextStyle(color: NotesApp.primaryTextColor)),
        backgroundColor: NotesApp.appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: NotesApp.primaryTextColor),
            onPressed: _isEditing ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: NotesApp.primaryTextColor),
            onPressed: _isEditing ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: NotesApp.primaryTextColor),
            onPressed: _isEditing ? _saveNote : null,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _toggleEditing,
        child: AbsorbPointer(
          absorbing: !_isEditing,
          child: Column(
            children: [
              _buildNoteDate(widget.note.dateCreated),
              _buildTitleInput(),
              _buildContentInput(),
            ],
          ),
        ),
      ),
    );
  }

  // Build note date display
  Widget _buildNoteDate(String dateCreated) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            dateCreated,
            style: const TextStyle(color: NotesApp.primaryTextColor),
          ),
        ],
      ),
    );
  }

  // Build title input field
  Widget _buildTitleInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _titleController,
        maxLines: 1,
        decoration: const InputDecoration(
          hintText: 'Enter title here',
          border: InputBorder.none,
          hintStyle: TextStyle(fontWeight: FontWeight.bold, color: NotesApp.primaryTextColor),
        ),
        style: const TextStyle(fontWeight: FontWeight.bold, color: NotesApp.primaryTextColor),
        cursorColor: NotesApp.highlightColor,
      ),
    );
  }

  // Build content input field
  Widget _buildContentInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter your note here',
            border: InputBorder.none,
            hintStyle: TextStyle(color: NotesApp.primaryTextColor),
          ),
          style: const TextStyle(color: NotesApp.primaryTextColor),
          cursorColor: NotesApp.highlightColor,
          onChanged: (text) {
            if (_isEditing) {
              _undoHistory.add(text);
            }
          },
        ),
      ),
    );
  }
}

class Note {
  String id;
  final String title;
  final String content;
  final String dateCreated;

  Note({
    this.id = '',
    required this.title,
    required this.content,
    required this.dateCreated,
  });

  Note.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'],
        content = json['content'],
        dateCreated = json['dateCreated'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'dateCreated': dateCreated,
        'id': id,
      };
}
