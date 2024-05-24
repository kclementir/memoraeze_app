import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FolderManager {
  static final FolderManager _instance = FolderManager._internal();

  factory FolderManager() {
    return _instance;
  }

  FolderManager._internal();

  final List<Map<String, dynamic>> _folders = [];
  List<Map<String, dynamic>> _allSets = []; // List to store all sets

  List<String> get folders => _folders.map((folder) => folder['name'] as String).toList();

  List<Map<String, dynamic>> get folderDetails => List.unmodifiable(_folders);

  Future<void> loadAllSets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> setsJson = prefs.getStringList('sets') ?? [];
    _allSets = setsJson.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  void addFolder(String folder, {String? description}) {
    _folders.add({'name': folder, 'description': description, 'sets': []});
  }

  void addSetToFolder(String folderName, Map<String, dynamic> set, {void Function(String folderName)? onDuplicate}) {
    for (var folder in _folders) {
      if (folder['name'] == folderName) {
        if (!_isSetInFolder(folder, set['title'])) {
          folder['sets'].add(set);
        } else {
          if (onDuplicate != null) {
            onDuplicate(folderName);
          }
        }
        break;
      }
    }
  }

  void updateFolder(String oldName, String newName, {String? description}) {
    for (var folder in _folders) {
      if (folder['name'] == oldName) {
        folder['name'] = newName;
        if (description != null) {
          folder['description'] = description;
        }
        break;
      }
    }
  }

  void removeFolder(String folderName) {
    _folders.removeWhere((folder) => folder['name'] == folderName);
  }

  void removeSetFromFolder(String folderName, String setTitle) {
    for (var folder in _folders) {
      if (folder['name'] == folderName) {
        folder['sets'].removeWhere((set) => set['title'] == setTitle);
        break;
      }
    }
  }

  bool _isSetInFolder(Map<String, dynamic> folder, String setTitle) {
    for (var set in folder['sets']) {
      if (set['title'] == setTitle) {
        return true;
      }
    }
    return false;
  }

  List<Map<String, dynamic>> getSetsInFolder(String folderName) {
    for (var folder in _folders) {
      if (folder['name'] == folderName) {
        return List<Map<String, dynamic>>.from(folder['sets']);
      }
    }
    return [];
  }

  List<Map<String, dynamic>> getAllSets() {
    return _allSets;
  }

  loadFoldersFromPrefs() {}
}

List<Map<String, dynamic>> _folders = [];

  List<Map<String, dynamic>> get folderDetails => _folders;

  Future<void> addFolder(String name, {String? description}) async {
    final folder = {
      'name': name,
      'description': description ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };
    _folders.add(folder);
    await _saveFoldersToPrefs();
  }

  Future<void> loadFoldersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> foldersJson = prefs.getStringList('folders') ?? [];
    _folders = foldersJson.map((f) => jsonDecode(f) as Map<String, dynamic>).toList();
  }

  Future<void> _saveFoldersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> foldersJson = _folders.map((f) => jsonEncode(f)).toList();
    await prefs.setStringList('folders', foldersJson);
  }

  Future<void> removeFolder(String name) async {
    _folders.removeWhere((folder) => folder['name'] == name);
    await _saveFoldersToPrefs();
  }

Future<void> _saveNotes() async {
  final prefs = await SharedPreferences.getInstance();
  var notes;
  List<String> notesJson = notes.map((note) => jsonEncode(note)).toList();
  await prefs.setStringList('notes', notesJson);
}

Future<void> _saveStudySets() async {
  final prefs = await SharedPreferences.getInstance();
  var studySets;
  List<String> setsJson = studySets.map((set) => jsonEncode(set)).toList();
  await prefs.setStringList('sets', setsJson);
}

Future<void> _saveFolders() async {
  final prefs = await SharedPreferences.getInstance();
  var folders;
  List<String> foldersJson = folders.map((folder) => jsonEncode(folder)).toList();
  await prefs.setStringList('folders', foldersJson);
}
