import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No Web configuration provided. Add your web configuration in this file.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'No iOS configuration provided. Add your iOS configuration in this file.',
        );
      default:
        throw UnsupportedError(
          'No configuration provided for {defaultTargetPlatform.toString()}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AlzaSyCo-geAZQXmuBcYfJRPfw7FnCY1_550Hws',
    appId: '1:761363975169:android:84cb27e67a45dd4e780400',
    messagingSenderId: '761363975169',
    projectId: 'notekep-64473',
    storageBucket:
        '', // Nếu có storageBucket hãy điền vào, nếu không thì để rỗng
  );
}
