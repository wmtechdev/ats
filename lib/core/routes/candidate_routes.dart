import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/middleware/auth_middleware.dart';
import 'package:ats/presentation/candidate/bindings/candidate_bindings.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_login_screen.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_signup_screen.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_forgot_password_screen.dart';
import 'package:ats/presentation/candidate/screens/dashboard/candidate_dashboard_screen.dart';
import 'package:ats/presentation/candidate/screens/profile/candidate_profile_screen.dart';
import 'package:ats/presentation/candidate/screens/jobs/jobs_list_screen.dart';
import 'package:ats/presentation/candidate/screens/jobs/job_details_screen.dart';
import 'package:ats/presentation/candidate/screens/applications/my_applications_screen.dart';
import 'package:ats/presentation/candidate/screens/documents/my_documents_screen.dart';

class CandidateRoutes {
  static const String initial = AppConstants.routeLogin;

  static List<GetPage> get routes => [
        // Candidate Auth Routes
        GetPage(
          name: AppConstants.routeLogin,
          page: () => const CandidateLoginScreen(),
          binding: CandidateBindings(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: AppConstants.routeSignUp,
          page: () => const CandidateSignUpScreen(),
          binding: CandidateBindings(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: AppConstants.routeForgotPassword,
          page: () => const CandidateForgotPasswordScreen(),
          binding: CandidateBindings(),
          middlewares: [AuthMiddleware()],
        ),

        // Candidate Routes
        GetPage(
          name: AppConstants.routeCandidateDashboard,
          page: () => const CandidateDashboardScreen(),
          binding: CandidateBindings(),
        ),
        GetPage(
          name: AppConstants.routeCandidateProfile,
          page: () => const CandidateProfileScreen(),
          binding: CandidateBindings(),
        ),
        GetPage(
          name: AppConstants.routeCandidateJobs,
          page: () => const JobsListScreen(),
          binding: CandidateBindings(),
        ),
        GetPage(
          name: AppConstants.routeCandidateJobDetails,
          page: () => const JobDetailsScreen(),
          binding: CandidateBindings(),
        ),
        GetPage(
          name: AppConstants.routeCandidateApplications,
          page: () => const MyApplicationsScreen(),
          binding: CandidateBindings(),
        ),
        GetPage(
          name: AppConstants.routeCandidateDocuments,
          page: () => const MyDocumentsScreen(),
          binding: CandidateBindings(),
        ),
      ];

  static GetPage get unknownRoute => GetPage(
        name: '/not-found',
        page: () => const CandidateLoginScreen(),
      );
}

