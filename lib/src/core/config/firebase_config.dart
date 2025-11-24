import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for RadarSafi
class FirebaseConfig {
  static const Map<String, dynamic> firebaseConfig = {
    'apiKey': 'AIzaSyCZpL0epBaQRZOPsogn9AKjdJ_KE-XZKGs',
    'authDomain': 'radarsafi.firebaseapp.com',
    'projectId': 'radarsafi',
    'storageBucket': 'radarsafi.firebasestorage.app',
    'messagingSenderId': '382335102998',
    'appId': '1:382335102998:web:b8d875970c8cffbb824537',
  };

  /// Initialize Firebase with the configuration
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey'] as String,
        authDomain: firebaseConfig['authDomain'] as String,
        projectId: firebaseConfig['projectId'] as String,
        storageBucket: firebaseConfig['storageBucket'] as String,
        messagingSenderId: firebaseConfig['messagingSenderId'] as String,
        appId: firebaseConfig['appId'] as String,
      ),
    );
  }
}

