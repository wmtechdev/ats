import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/routes/candidate_routes.dart';
import 'package:ats/core/theme/app_theme.dart';

class CandidateApp extends StatelessWidget {
  const CandidateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ATS - Candidate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: CandidateRoutes.initial,
      getPages: CandidateRoutes.routes,
      unknownRoute: CandidateRoutes.unknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

