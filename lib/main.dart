import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/notes.dart';
import 'screens/create.dart';
import 'screens/library.dart';
import 'screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/notes': (context) => const NotesScreen(),
        '/create': (context) => const CreateSetScreen(),
        '/library': (context) => const LibraryScreen(tabIndex: 0),
        '/login': (context) => const LoginScreen(),
        '/allNotes': (context) => const NotesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/library') {
          final tabIndex = settings.arguments as int? ?? 0;
          return MaterialPageRoute(
            builder: (context) => LibraryScreen(tabIndex: tabIndex),
          );
        }
        return null;
      },
    );
  }
}
