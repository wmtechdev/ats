import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/data/repositories/auth_repository_impl.dart';
import 'package:ats/domain/repositories/auth_repository.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authRepo = Get.find<AuthRepository>();
    
    if (authRepo is AuthRepositoryImpl) {
      final currentUser = authRepo.getCurrentUser();
      
      if (currentUser == null) {
        return const RouteSettings(name: AppConstants.routeLogin);
      }
      
      // Check if user is admin
      if (currentUser.role != AppConstants.roleAdmin) {
        // Not an admin, redirect to candidate dashboard
        return const RouteSettings(name: AppConstants.routeCandidateDashboard);
      }
    }
    
    return null;
  }
}

