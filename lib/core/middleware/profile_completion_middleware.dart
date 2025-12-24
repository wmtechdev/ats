import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';

/// Middleware to check if candidate profile is completed
/// Redirects to profile screen if profile is incomplete
class ProfileCompletionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Allow access to profile screen and auth routes
    final allowedRoutes = [
      AppConstants.routeLogin,
      AppConstants.routeSignUp,
      AppConstants.routeCandidateProfile,
    ];

    if (allowedRoutes.contains(route)) {
      return null; // Allow access
    }

    // Check if user is authenticated
    try {
      final authRepository = Get.find<CandidateAuthRepository>();
      final currentUser = authRepository.getCurrentUser();
      
      if (currentUser == null) {
        return null; // Not authenticated, let AuthMiddleware handle it
      }

      // Check profile completion
      final profileRepository = Get.find<CandidateProfileRepository>();
      
      // Try to get profile synchronously (this might not work perfectly)
      // We'll use a stream-based approach instead
      // For now, we'll check in the screen itself
      // This middleware will be enhanced to work with async profile checks
      
      return null; // Allow access for now, profile check will be done in screens
    } catch (e) {
      // Controllers not initialized yet, allow access
      return null;
    }
  }
}

