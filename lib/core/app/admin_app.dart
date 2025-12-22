import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/routes/admin_routes.dart';
import 'package:ats/core/theme/app_theme.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ATS - Admin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AdminRoutes.initial,
      getPages: AdminRoutes.routes,
      unknownRoute: AdminRoutes.unknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

