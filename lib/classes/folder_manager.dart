class FolderManager {
  static final FolderManager _instance = FolderManager._internal();

  factory FolderManager() {
    return _instance;
  }

  FolderManager._internal();

  final List<Map<String, String?>> _folders = [];

  List<String> get folders => _folders.map((folder) => folder['name']!).toList();

  List<Map<String, String?>> get folderDetails => List.unmodifiable(_folders);

  void addFolder(String folder, {String? description}) {
    _folders.add({'name': folder, 'description': description});
  }
}
