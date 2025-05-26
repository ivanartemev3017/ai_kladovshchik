import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBG4wb8bJ-oAeFLbLGunvKBmDFspRwKCvs",
    authDomain: "ai-kladovshchik.firebaseapp.com",
    projectId: "ai-kladovshchik",
    storageBucket: "ai-kladovshchik.firebasestorage.app",
    messagingSenderId: "359840566413",
    appId: "1:359840566413:web:f40968db9da07585d066c4",
    measurementId: "G-0CCYQTLLSC",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBG4wb8bJ-oAeFLbLGunvKBmDFspRwKCvs",
    appId: "1:359840566413:web:f40968db9da07585d066c4",
    messagingSenderId: "359840566413",
    projectId: "ai-kladovshchik",
    storageBucket: "ai-kladovshchik.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBG4wb8bJ-oAeFLbLGunvKBmDFspRwKCvs",
    appId: "1:359840566413:web:f40968db9da07585d066c4",
    messagingSenderId: "359840566413",
    projectId: "ai-kladovshchik",
    storageBucket: "ai-kladovshchik.firebasestorage.app",
    iosClientId: "",
    iosBundleId: "com.example.aiKladovshchikFinal",
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyBG4wb8bJ-oAeFLbLGunvKBmDFspRwKCvs",
    appId: "1:359840566413:web:f40968db9da07585d066c4",
    messagingSenderId: "359840566413",
    projectId: "ai-kladovshchik",
    storageBucket: "ai-kladovshchik.firebasestorage.app",
  );
}
