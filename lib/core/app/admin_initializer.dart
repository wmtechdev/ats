import 'package:ats/core/app/app_initializer.dart';

class AdminInitializer {
  static Future<void> initialize() async {
    // Initialize base app dependencies (Firebase, AuthRepository, etc.)
    await AppInitializer.initialize();
    
    // Admin-specific initialization can be added here
    // For example: admin-specific services, analytics, etc.
  }
}

