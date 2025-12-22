import 'package:ats/core/app/app_initializer.dart';

class CandidateInitializer {
  static Future<void> initialize() async {
    // Initialize base app dependencies (Firebase, AuthRepository, etc.)
    await AppInitializer.initialize();
    
    // Candidate-specific initialization can be added here
    // For example: candidate-specific services, analytics, etc.
  }
}

