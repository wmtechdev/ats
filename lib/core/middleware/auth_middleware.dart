import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/data/repositories/auth_repository_impl.dart';
import 'package:ats/domain/repositories/auth_repository.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if AuthRepository is registered
    if (!Get.isRegistered<AuthRepository>()) {
      // If not registered yet, allow the route to proceed
      // The binding will register it when the route loads
      return null;
    }

    final authRepo = Get.find<AuthRepository>();
    
    // Check if user is authenticated
    if (authRepo is AuthRepositoryImpl) {
      final currentUser = authRepo.getCurrentUser();
      
      if (currentUser == null) {
        // Not authenticated, allow access to auth routes only
        if (route != AppConstants.routeLogin && 
            route != AppConstants.routeSignUp &&
            route != AppConstants.routeAdminLogin &&
            route != AppConstants.routeAdminSignUp) {
          return const RouteSettings(name: AppConstants.routeLogin);
        }
      } else {
        // Authenticated, redirect away from auth routes based on role
        final userRole = currentUser.role;
        
        // Candidate auth routes
        if (route == AppConstants.routeLogin || 
            route == AppConstants.routeSignUp) {
          if (userRole == AppConstants.roleAdmin) {
            return const RouteSettings(name: AppConstants.routeAdminDashboard);
          } else {
            return const RouteSettings(name: AppConstants.routeCandidateDashboard);
          }
        }
        
        // Admin auth routes
        if (route == AppConstants.routeAdminLogin || 
            route == AppConstants.routeAdminSignUp) {
          if (userRole == AppConstants.roleAdmin) {
            return const RouteSettings(name: AppConstants.routeAdminDashboard);
          } else {
            return const RouteSettings(name: AppConstants.routeCandidateDashboard);
          }
        }
      }
    }
    
    return null;
  }
}

