import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/routes/app_routes.dart';
import 'package:ats/core/routes/candidate_routes.dart';
import 'package:ats/core/routes/admin_routes.dart';
import 'package:ats/core/theme/app_theme.dart';

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ATS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.initial,
      getPages: [
        ...CandidateRoutes.routes,
        ...AdminRoutes.routes,
      ],
      unknownRoute: AppRoutes.unknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

