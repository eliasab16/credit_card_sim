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
    apiKey: 'AIzaSyDpYcjuMTAwVPPULJsVdVmeZBF0OX43rnU',
    appId: '1:135455508661:web:fb83dc34d11990f8db56fc',
    messagingSenderId: '135455508661',
    projectId: 'credit-card-sim',
    authDomain: 'credit-card-sim.firebaseapp.com',
    storageBucket: 'credit-card-sim.appspot.com',
    measurementId: 'G-RTSY037QDN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBo80KGoZjy2aNcn1kvQry9U1zIk35qVxM',
    appId: '1:135455508661:android:f298e28d45feb533db56fc',
    messagingSenderId: '135455508661',
    projectId: 'credit-card-sim',
    storageBucket: 'credit-card-sim.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCyUuZAeo_H72UPqmXe2TV92Z1AV8NlTeM',
    appId: '1:135455508661:ios:cd953bb3f181ba2ddb56fc',
    messagingSenderId: '135455508661',
    projectId: 'credit-card-sim',
    storageBucket: 'credit-card-sim.appspot.com',
    iosBundleId: 'com.example.creditCardSim',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCyUuZAeo_H72UPqmXe2TV92Z1AV8NlTeM',
    appId: '1:135455508661:ios:b700c75e79398265db56fc',
    messagingSenderId: '135455508661',
    projectId: 'credit-card-sim',
    storageBucket: 'credit-card-sim.appspot.com',
    iosBundleId: 'com.example.creditCardSim.RunnerTests',
  );
}