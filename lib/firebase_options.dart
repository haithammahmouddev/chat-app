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
    apiKey: 'AIzaSyBxXDYxGSPScco19UK3WT5mOTJM88_wOcw',
    appId: '1:1056972653449:web:eae62824a10007a3605758',
    messagingSenderId: '1056972653449',
    projectId: 'whats-a-c110f',
    authDomain: 'whats-a-c110f.firebaseapp.com',
    storageBucket: 'whats-a-c110f.firebasestorage.app',
    measurementId: 'G-2VTT785H3N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDthEpQ4mH3vWcCPZDPbb5qhqmWQKylHEY',
    appId: '1:1056972653449:android:ffb5f190cfbc3975605758',
    messagingSenderId: '1056972653449',
    projectId: 'whats-a-c110f',
    storageBucket: 'whats-a-c110f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8OFCQAMkoAsYMZ3mOsmoNyn0vLOBGsUY',
    appId: '1:1056972653449:ios:0c349bece00199f8605758',
    messagingSenderId: '1056972653449',
    projectId: 'whats-a-c110f',
    storageBucket: 'whats-a-c110f.firebasestorage.app',
    iosBundleId: 'com.haitham.whatsApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8OFCQAMkoAsYMZ3mOsmoNyn0vLOBGsUY',
    appId: '1:1056972653449:ios:0c349bece00199f8605758',
    messagingSenderId: '1056972653449',
    projectId: 'whats-a-c110f',
    storageBucket: 'whats-a-c110f.firebasestorage.app',
    iosBundleId: 'com.haitham.whatsApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxXDYxGSPScco19UK3WT5mOTJM88_wOcw',
    appId: '1:1056972653449:web:2a62d89c4108323f605758',
    messagingSenderId: '1056972653449',
    projectId: 'whats-a-c110f',
    authDomain: 'whats-a-c110f.firebaseapp.com',
    storageBucket: 'whats-a-c110f.firebasestorage.app',
    measurementId: 'G-FQ1XK3B95P',
  );
}
