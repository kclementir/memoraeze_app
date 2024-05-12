class FolderManager {
  static final FolderManager _instance = FolderManager._internal();

  factory FolderManager() {
    return _instance;
  }

  FolderManager._internal();

  final List<String> _folders = [];

  List<String> get folders => List.unmodifiable(_folders);

  void addFolder(String folder) {
    _folders.add(folder);
  }
}
