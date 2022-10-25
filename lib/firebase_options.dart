// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCfaBZsc81Rnmo-YnhhGkZ9apE54EQ2R_8',
    appId: '1:362501936195:web:36ce23e2fa99df0182b0f6',
    messagingSenderId: '362501936195',
    projectId: 'aumiau-33da2',
    authDomain: 'aumiau-33da2.firebaseapp.com',
    storageBucket: 'aumiau-33da2.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1lYogRLV9YYSF--chKy3OwQECA17dUqc',
    appId: '1:362501936195:android:2e76ec6a7b63e3ee82b0f6',
    messagingSenderId: '362501936195',
    projectId: 'aumiau-33da2',
    storageBucket: 'aumiau-33da2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCN3OrWBte4r9IpFSHxw3cAHH-jWjTv72o',
    appId: '1:362501936195:ios:b47a9eed21bea66582b0f6',
    messagingSenderId: '362501936195',
    projectId: 'aumiau-33da2',
    storageBucket: 'aumiau-33da2.appspot.com',
    iosClientId: '362501936195-rsvke2kne30rdm0dq5ij9rl77pt6k0tu.apps.googleusercontent.com',
    iosBundleId: 'com.example.tcc',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCN3OrWBte4r9IpFSHxw3cAHH-jWjTv72o',
    appId: '1:362501936195:ios:b47a9eed21bea66582b0f6',
    messagingSenderId: '362501936195',
    projectId: 'aumiau-33da2',
    storageBucket: 'aumiau-33da2.appspot.com',
    iosClientId: '362501936195-rsvke2kne30rdm0dq5ij9rl77pt6k0tu.apps.googleusercontent.com',
    iosBundleId: 'com.example.tcc',
  );
}
