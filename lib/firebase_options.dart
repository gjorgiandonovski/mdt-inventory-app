import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _env('FIREBASE_WEB_API_KEY'),
        appId: _env('FIREBASE_WEB_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        authDomain: _env('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET'),
        measurementId: _env('FIREBASE_WEB_MEASUREMENT_ID'),
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _env('FIREBASE_ANDROID_API_KEY'),
        appId: _env('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _env('FIREBASE_IOS_API_KEY'),
        appId: _env('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: _env('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: _env('FIREBASE_MACOS_API_KEY'),
        appId: _env('FIREBASE_MACOS_APP_ID'),
        messagingSenderId: _env('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('FIREBASE_PROJECT_ID'),
        storageBucket: _env('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: _env('FIREBASE_MACOS_BUNDLE_ID'),
      );

  static String _env(String key) {
    const empty = '';
    final value = String.fromEnvironment(key, defaultValue: empty).trim();
    if (value.isEmpty) {
      throw StateError('Missing --dart-define for $key');
    }
    return value;
  }
}
