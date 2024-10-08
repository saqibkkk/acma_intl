// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCY6zd6WS7lOpiG5XTYHWQklNsehPoFR6s',
    appId: '1:557457440311:web:6a8a7bd07c7237cb2989b2',
    messagingSenderId: '557457440311',
    projectId: 'acma-intl',
    authDomain: 'acma-intl.firebaseapp.com',
    storageBucket: 'acma-intl.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTzGtNYc9rqQIcYsj6gV2eofMFHIRGnp4',
    appId: '1:557457440311:android:b13ef15c14185c102989b2',
    messagingSenderId: '557457440311',
    projectId: 'acma-intl',
    storageBucket: 'acma-intl.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8amczDy86Ea8Z0KWwdi29UlmQWFVEaH0',
    appId: '1:557457440311:ios:55a440b82da0dea72989b2',
    messagingSenderId: '557457440311',
    projectId: 'acma-intl',
    storageBucket: 'acma-intl.appspot.com',
    iosBundleId: 'com.saqib.acmaIntl',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCY6zd6WS7lOpiG5XTYHWQklNsehPoFR6s',
    appId: '1:557457440311:web:709758cc57d7a3242989b2',
    messagingSenderId: '557457440311',
    projectId: 'acma-intl',
    authDomain: 'acma-intl.firebaseapp.com',
    storageBucket: 'acma-intl.appspot.com',
  );
}
