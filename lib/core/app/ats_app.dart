import 'package:flutter/material.dart';
import 'package:ats/core/app/app_material.dart';
import 'package:ats/core/app/candidate_app.dart';
import 'package:ats/core/app/admin_app.dart';

enum AppType { candidate, admin, unified }

class ATSApp extends StatelessWidget {
  final AppType appType;

  const ATSApp({
    super.key,
    this.appType = AppType.unified,
  });

  @override
  Widget build(BuildContext context) {
    switch (appType) {
      case AppType.candidate:
        return const CandidateApp();
      case AppType.admin:
        return const AdminApp();
      case AppType.unified:
        return const AppMaterial();
    }
  }
}

