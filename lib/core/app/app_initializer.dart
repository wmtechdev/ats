import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ats/firebase_options.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Note: Auth repositories are now registered in their respective bindings
    // (AdminBindings and CandidateBindings) for complete isolation
  }
}

