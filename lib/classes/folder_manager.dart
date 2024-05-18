class FolderManager {
  static final FolderManager _instance = FolderManager._internal();

  factory FolderManager() {
    return _instance;
  }

  FolderManager._internal();

  final List<Map<String, dynamic>> _folders = [];

  List<String> get folders => _folders.map((folder) => folder['name'] as String).toList();

  List<Map<String, dynamic>> get folderDetails => List.unmodifiable(_folders);

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
}
