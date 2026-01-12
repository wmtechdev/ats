import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ats/core/constants/app_constants.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check Firebase Auth directly for synchronous check
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // List of public auth routes that don't require authentication
    final publicRoutes = [
      AppConstants.routeLogin,
      AppConstants.routeSignUp,
      AppConstants.routeForgotPassword,
      AppConstants.routeAdminLogin,
    ];

    // Get current route to check if user is navigating between auth screens
    final currentRoute = Get.currentRoute;

    // Candidate auth routes
    final candidateAuthRoutes = [
      AppConstants.routeLogin,
      AppConstants.routeSignUp,
      AppConstants.routeForgotPassword,
    ];

    // Admin auth routes
    final adminAuthRoutes = [AppConstants.routeAdminLogin];

    // Check if navigating between auth screens of the same type
    final isNavigatingBetweenCandidateAuth =
        candidateAuthRoutes.contains(currentRoute) &&
        candidateAuthRoutes.contains(route);
    final isNavigatingBetweenAdminAuth =
        adminAuthRoutes.contains(currentRoute) &&
        adminAuthRoutes.contains(route);

    if (firebaseUser == null) {
      // Not authenticated - allow only public auth routes
      if (publicRoutes.contains(route)) {
        return null; // Allow access to auth routes
      }
      // Redirect to login for protected routes
      return const RouteSettings(name: AppConstants.routeLogin);
    } else {
      // Authenticated - redirect away from auth routes
      // BUT allow navigation between auth screens of the same type
      if (publicRoutes.contains(route)) {
        // Allow navigation between candidate auth screens
        if (isNavigatingBetweenCandidateAuth) {
          return null; // Allow switching between login and signup
        }
        // Allow navigation between admin auth screens
        if (isNavigatingBetweenAdminAuth) {
          return null; // Allow switching between admin login and signup
        }
        // User is logged in but trying to access auth routes from outside
        // Redirect to candidate dashboard (default)
        return const RouteSettings(name: AppConstants.routeCandidateDashboard);
      }
    }

    return null; // Allow access to protected routes
  }
}
