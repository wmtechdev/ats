import 'package:flutter/material.dart';
import 'package:ats/core/app/app_initializer.dart';
import 'package:ats/core/app/ats_app.dart';

/// Main entry point for the unified ATS application
/// 
/// This runs both candidate and admin routes together.
/// For isolated apps, use:
/// - `main_candidate.dart` for candidate-only app
/// - `main_admin.dart` for admin-only app
void main() async {
  await AppInitializer.initialize();
  runApp(const ATSApp(appType: AppType.admin,));
}
