import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_login_screen.dart';

/// Central route configuration for the app
/// Note: Actual routes are defined in CandidateRoutes and AdminRoutes
/// This class only provides initial route and unknown route fallback
class AppRoutes {
  /// Initial route when app starts
  static const String initial = AppConstants.routeLogin;

  /// Fallback route for unknown/non-existent routes
  static GetPage get unknownRoute => GetPage(
        name: '/not-found',
        page: () => const CandidateLoginScreen(),
      );
}
