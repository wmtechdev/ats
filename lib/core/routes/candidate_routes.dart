import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/middleware/auth_middleware.dart';
import 'package:ats/core/middleware/profile_completion_middleware.dart';
import 'package:ats/presentation/candidate/bindings/candidate_bindings.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_login_screen.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_signup_screen.dart';
import 'package:ats/presentation/candidate/screens/dashboard/candidate_dashboard_screen.dart';
import 'package:ats/presentation/candidate/screens/profile/candidate_profile_screen.dart';
import 'package:ats/presentation/candidate/screens/jobs/jobs_list_screen.dart';
import 'package:ats/presentation/candidate/screens/jobs/job_details_screen.dart';
import 'package:ats/presentation/candidate/screens/applications/my_applications_screen.dart';
import 'package:ats/presentation/candidate/screens/documents/my_documents_screen.dart';
import 'package:ats/presentation/candidate/screens/documents/my_document_create_screen.dart';

class CandidateRoutes {
  static const String initial = AppConstants.routeLogin;

  static List<GetPage> get routes => [
    // Candidate Auth Routes
    GetPage(
      name: AppConstants.routeLogin,
      page: () => const CandidateLoginScreen(),
      binding: CandidateBindings(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeSignUp,
      page: () => const CandidateSignUpScreen(),
      binding: CandidateBindings(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Candidate Routes
    GetPage(
      name: AppConstants.routeCandidateDashboard,
      page: () => const CandidateDashboardScreen(),
      binding: CandidateBindings(),
      middlewares: [ProfileCompletionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeCandidateProfile,
      page: () => const CandidateProfileScreen(),
      binding: CandidateBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeCandidateJobs,
      page: () => const JobsListScreen(),
      binding: CandidateBindings(),
      middlewares: [ProfileCompletionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeCandidateJobDetails,
      page: () => const JobDetailsScreen(),
      binding: CandidateBindings(),
      middlewares: [ProfileCompletionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeCandidateApplications,
      page: () => const MyApplicationsScreen(),
      binding: CandidateBindings(),
      middlewares: [ProfileCompletionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeCandidateDocuments,
      page: () => const MyDocumentsScreen(),
      binding: CandidateBindings(),
      middlewares: [ProfileCompletionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppConstants.routeCandidateCreateDocument,
      page: () => const MyDocumentCreateScreen(),
      binding: CandidateBindings(),
      middlewares: [ProfileCompletionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  static GetPage get unknownRoute =>
      GetPage(name: '/not-found', page: () => const CandidateLoginScreen());
}
