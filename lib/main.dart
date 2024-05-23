import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'screens/home.dart';
import 'screens/notes.dart';
import 'screens/create.dart';
import 'screens/library.dart';
import 'screens/profile.dart';
import 'screens/login.dart'; // Import LoginScreen
import 'screens/create_account.dart'; // Import CreateAccountScreen
import 'classes/folder_manager.dart'; // Import the FolderManager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoraeze',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF102F50),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    const NotesScreen(),
    const CreateSetScreen(),
    const LibraryScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: _selectedIndex < 4
            ? _widgetOptions.elementAt(_selectedIndex)
            : const SizedBox.shrink(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      endDrawer: _buildProfileDrawer(context),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded), label: 'Create'),
        BottomNavigationBarItem(
            icon: Icon(Icons.library_books), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFFC3D1DB),
      unselectedItemColor: const Color(0xFF306C97),
      selectedLabelStyle: const TextStyle(color: Color(0xFFC3D1DB)),
      unselectedLabelStyle: const TextStyle(color: Color(0xFF306C97)),
      onTap: (index) {
        if (index == 2) {
          _showCreateDrawer(context);
        } else {
          _onItemTapped(index);
        }
      },
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      elevation: 0.0,
    );
  }

  void _showCreateDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {},
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2B4057),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Icon(Icons.drag_handle_rounded, size: 36, color: Color(0xFFC3D1DB)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Column(
                      children: [
                        _buildOptionContainer(
                          leadingIcon: Icons.book_outlined,
                          title: 'Study Set',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateSetScreen()),
                            );
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        _buildOptionContainer(
                          leadingIcon: Icons.folder_open_rounded,
                          title: 'Folder',
                          onTap: () {
                            Navigator.pop(context);
                            _showFolderDialog(context);
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionContainer({
    required IconData leadingIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: MediaQuery.of(context).size.width * 0.04,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF102F50),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(leadingIcon, color: const Color(0xFFC3D1DB)),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(title, style: const TextStyle(color: Color(0xFFC3D1DB))),
          ],
        ),
      ),
    );
  }

  void _showFolderDialog(BuildContext context) {
    String newFolderName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B4057),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Create folder', style: TextStyle(color: Color(0xFFC3D1DB))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) => newFolderName = value,
                  decoration: InputDecoration(
                    hintText: 'Folder name',
                    hintStyle: TextStyle(color: const Color(0xFFC3D1DB).withOpacity(0.6)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF59A6BF)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFC3D1DB)),
                  cursorColor: const Color(0xFF59A6BF),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: TextStyle(color: const Color(0xFFC3D1DB).withOpacity(0.6)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF59A6BF)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFC3D1DB)),
                  cursorColor: const Color(0xFF59A6BF),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF59A6BF), fontWeight: FontWeight.bold)),
              onPressed: () {
                if (newFolderName.isNotEmpty) {
                  FolderManager().addFolder(newFolderName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: const Text('User Profile', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
