// ╔══════════════════════════════════════════════════════════════════════╗
// ║  PLACEHOLDER — Run `flutterfire configure` to generate real values  ║
// ╚══════════════════════════════════════════════════════════════════════╝
//
// This file is a placeholder so the project compiles before Firebase is
// configured. Replace it by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command will overwrite this file with your project-specific keys.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android ──

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwtOsVf1NI-rCUM1vp9Hzk7XFG6-7NbSo',
    appId: '1:767665758635:android:f75c4f29da465bba50b2ee',
    messagingSenderId: '767665758635',
    projectId: 'eden-sound',
    storageBucket: 'eden-sound.firebasestorage.app',
  );

  // TODO: Replace these placeholder values with your Firebase project config.

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAoz4YhzW4w351_4t1MK5yHO2WyeCI5wls',
    appId: '1:767665758635:ios:f623b3f64c16c23950b2ee',
    messagingSenderId: '767665758635',
    projectId: 'eden-sound',
    storageBucket: 'eden-sound.firebasestorage.app',
    iosBundleId: 'com.example.edenx',
  );

  // ── iOS ──

  // ── Web ──
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project-id',
    storageBucket: 'your-firebase-project-id.firebasestorage.app',
    authDomain: 'your-firebase-project-id.firebaseapp.com',
  );
}