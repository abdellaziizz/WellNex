// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_methods
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for WellNex app.
///
/// Example configuration file generated with Firebase CLI
/// For more information, see: https://firebase.google.com/docs/flutter/setup
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
        // Use web configuration for Windows
        return web;
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

  // Updated configuration based on the actual Firebase project settings
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDTs4ay7m4rb7AEsjPmxm2jgM8-S5sSI54',
    appId: '1:525032895830:web:fc99885484bcb0791e12f7',
    messagingSenderId: '525032895830',
    projectId: 'wellnexapp-24d59',
    authDomain: 'wellnexapp-24d59.firebaseapp.com',
    storageBucket: 'wellnexapp-24d59.firebasestorage.app',
    measurementId: 'G-KHLN8HTDXJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTs4ay7m4rb7AEsjPmxm2jgM8-S5sSI54',
    appId: '1:525032895830:android:fc99885484bcb0791e12f7',
    messagingSenderId: '525032895830',
    projectId: 'wellnexapp-24d59',
    storageBucket: 'wellnexapp-24d59.firebasestorage.app',
    measurementId: 'G-KHLN8HTDXJ',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTs4ay7m4rb7AEsjPmxm2jgM8-S5sSI54',
    appId: '1:525032895830:ios:fc99885484bcb0791e12f7', 
    messagingSenderId: '525032895830',
    projectId: 'wellnexapp-24d59',
    storageBucket: 'wellnexapp-24d59.firebasestorage.app',
    iosClientId: '525032895830-ios.apps.googleusercontent.com', 
    iosBundleId: 'com.example.final_project',
    measurementId: 'G-KHLN8HTDXJ',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDTs4ay7m4rb7AEsjPmxm2jgM8-S5sSI54',
    appId: '1:525032895830:ios:fc99885484bcb0791e12f7', 
    messagingSenderId: '525032895830',
    projectId: 'wellnexapp-24d59',
    storageBucket: 'wellnexapp-24d59.firebasestorage.app',
    iosClientId: '525032895830-macos.apps.googleusercontent.com', 
    iosBundleId: 'com.example.final_project',
    measurementId: 'G-KHLN8HTDXJ',
  );
}