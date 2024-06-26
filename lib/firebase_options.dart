// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwMjWPQ-N4V7KKpzfezSB0YauhvSA1SpQ',
    appId: '1:1071605821511:web:2795e9c604b5dfdf9fc162',
    messagingSenderId: '1071605821511',
    projectId: 'flashcard-app-300e0',
    authDomain: 'flashcard-app-300e0.firebaseapp.com',
    databaseURL: 'https://flashcard-app-300e0-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'flashcard-app-300e0.appspot.com',
    measurementId: 'G-53VJ5DBTVY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZdgopoFQNROcciH0vUZkr0SdXSLf4XBE',
    appId: '1:1071605821511:android:e50dfa8b5685edba9fc162',
    messagingSenderId: '1071605821511',
    projectId: 'flashcard-app-300e0',
    databaseURL: 'https://flashcard-app-300e0-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'flashcard-app-300e0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIoED5YZfawGh7Qv6FsSdcGh5OVloHEZw',
    appId: '1:1071605821511:ios:08e6f5117f5602eb9fc162',
    messagingSenderId: '1071605821511',
    projectId: 'flashcard-app-300e0',
    databaseURL: 'https://flashcard-app-300e0-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'flashcard-app-300e0.appspot.com',
    iosBundleId: 'com.example.memoraezeFlashcardApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIoED5YZfawGh7Qv6FsSdcGh5OVloHEZw',
    appId: '1:1071605821511:ios:08e6f5117f5602eb9fc162',
    messagingSenderId: '1071605821511',
    projectId: 'flashcard-app-300e0',
    databaseURL: 'https://flashcard-app-300e0-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'flashcard-app-300e0.appspot.com',
    iosBundleId: 'com.example.memoraezeFlashcardApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCwMjWPQ-N4V7KKpzfezSB0YauhvSA1SpQ',
    appId: '1:1071605821511:web:9120776cafb961269fc162',
    messagingSenderId: '1071605821511',
    projectId: 'flashcard-app-300e0',
    authDomain: 'flashcard-app-300e0.firebaseapp.com',
    databaseURL: 'https://flashcard-app-300e0-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'flashcard-app-300e0.appspot.com',
    measurementId: 'G-XY4KDVE10S',
  );

}