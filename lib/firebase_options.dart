// Fichier généré automatiquement.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

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
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyFakeKeyForTestingOnly123456789',
    appId: '1:123456789:web:123456789',
    messagingSenderId: '123456789',
    projectId: 'gp-manager-test',
    authDomain: 'gp-manager-test.firebaseapp.com',
    databaseURL: 'https://gp-manager-test.firebaseio.com',
    storageBucket: 'gp-manager-test.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyFakeKeyForTestingOnly123456789',
    appId: '1:123456789:android:123456789',
    messagingSenderId: '123456789',
    projectId: 'gp-manager-test',
    storageBucket: 'gp-manager-test.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyFakeKeyForTestingOnly123456789',
    appId: '1:123456789:ios:123456789',
    messagingSenderId: '123456789',
    projectId: 'gp-manager-test',
    storageBucket: 'gp-manager-test.appspot.com',
    iosBundleId: 'com.example.gpManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyFakeKeyForTestingOnly123456789',
    appId: '1:123456789:macos:123456789',
    messagingSenderId: '123456789',
    projectId: 'gp-manager-test',
    storageBucket: 'gp-manager-test.appspot.com',
    iosBundleId: 'com.example.gpManager',
  );
}
