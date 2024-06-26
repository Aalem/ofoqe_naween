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
    apiKey: 'AIzaSyBA6L4vXturOQT1G0KMLFPqu33v29gSR2E',
    appId: '1:38736383570:web:00f7b9ad8689935e25198b',
    messagingSenderId: '38736383570',
    projectId: 'ofoqe-naween',
    authDomain: 'ofoqe-naween.firebaseapp.com',
    storageBucket: 'ofoqe-naween.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLWE0YqN_-sx0a3vbr-gb4eAfb5jm6U00',
    appId: '1:38736383570:android:21ac26f0a2ece2da25198b',
    messagingSenderId: '38736383570',
    projectId: 'ofoqe-naween',
    storageBucket: 'ofoqe-naween.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXQmqlw_4I1XUWy5jHqQ3EnzIEI-DOalo',
    appId: '1:38736383570:ios:b000692eb6e8626e25198b',
    messagingSenderId: '38736383570',
    projectId: 'ofoqe-naween',
    storageBucket: 'ofoqe-naween.appspot.com',
    iosBundleId: 'com.example.ofoqeNaween',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXQmqlw_4I1XUWy5jHqQ3EnzIEI-DOalo',
    appId: '1:38736383570:ios:b000692eb6e8626e25198b',
    messagingSenderId: '38736383570',
    projectId: 'ofoqe-naween',
    storageBucket: 'ofoqe-naween.appspot.com',
    iosBundleId: 'com.example.ofoqeNaween',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBA6L4vXturOQT1G0KMLFPqu33v29gSR2E',
    appId: '1:38736383570:web:fef6c46050f0c32425198b',
    messagingSenderId: '38736383570',
    projectId: 'ofoqe-naween',
    authDomain: 'ofoqe-naween.firebaseapp.com',
    storageBucket: 'ofoqe-naween.appspot.com',
  );

}