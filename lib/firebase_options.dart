// このファイルは flutterfire configure で自動生成されます。
// Firebase プロジェクトを設定後、このファイルを削除して
// flutterfire configure を実行してください。
//
// $ flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgGjmmIwK3VlufuJJdgmKAM1jdxNjUMng',
    appId: '1:445346159301:web:e5cc24ea1cb7bc9249aeac',
    messagingSenderId: '445346159301',
    projectId: 'todoapp-8964d',
    authDomain: 'todoapp-8964d.firebaseapp.com',
    storageBucket: 'todoapp-8964d.firebasestorage.app',
    measurementId: 'G-CCLBNLY9NF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNVl0RjrWbV7xWiRTxvuogTLJRSrfsk0w',
    appId: '1:445346159301:android:6951dc998f7c0bfd49aeac',
    messagingSenderId: '445346159301',
    projectId: 'todoapp-8964d',
    storageBucket: 'todoapp-8964d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1J-T6vd_fdIzI9Gz7DCfm4xc5yaDh1GI',
    appId: '1:445346159301:ios:61c5d593f1b53dae49aeac',
    messagingSenderId: '445346159301',
    projectId: 'todoapp-8964d',
    storageBucket: 'todoapp-8964d.firebasestorage.app',
    iosBundleId: 'com.thousandhorse.todoApp',
  );

}