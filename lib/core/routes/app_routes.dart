import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/middleware/auth_middleware.dart';
import 'package:ats/presentation/candidate/bindings/candidate_bindings.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_login_screen.dart';
import 'package:ats/presentation/candidate/screens/auth/candidate_signup_screen.dart';
import 'package:ats/presentation/candidate/screens/dashboard/candidate_dashboard_screen.dart';
import 'package:ats/presentation/candidate/screens/profile/candidate_profile_screen.dart';
import 'package:ats/presentation/candidate/screens/jobs/jobs_list_screen.dart';
import 'package:ats/presentation/candidate/screens/jobs/job_details_screen.dart';
import 'package:ats/presentation/candidate/screens/applications/my_applications_screen.dart';
import 'package:ats/presentation/candidate/screens/documents/my_documents_screen.dart';
import 'package:ats/presentation/admin/bindings/admin_bindings.dart';
import 'package:ats/presentation/admin/screens/auth/admin_login_screen.dart';
import 'package:ats/presentation/admin/screens/auth/admin_signup_screen.dart';
import 'package:ats/presentation/admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:ats/presentation/admin/screens/jobs/admin_jobs_list_screen.dart';
import 'package:ats/presentation/admin/screens/jobs/admin_job_create_screen.dart';
import 'package:ats/presentation/admin/screens/jobs/admin_job_edit_screen.dart';
import 'package:ats/presentation/admin/screens/candidates/admin_candidates_list_screen.dart';
import 'package:ats/presentation/admin/screens/candidates/admin_candidate_details_screen.dart';
import 'package:ats/presentation/admin/screens/document_types/admin_document_types_screen.dart';
import 'package:ats/presentation/admin/screens/admins/admin_manage_admins_screen.dart';

class AppRoutes {
  static const initial = AppConstants.routeLogin;

  static final List<GetPage> routes = [
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
    // Admin Auth Routes
    GetPage(
      name: AppConstants.routeAdminLogin,
      page: () => const AdminLoginScreen(),
      binding: AdminBindings(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppConstants.routeAdminSignUp,
      page: () => const AdminSignUpScreen(),
      binding: AdminBindings(),
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

    // Admin Routes
    GetPage(
      name: AppConstants.routeAdminDashboard,
      page: () => const AdminDashboardScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminJobs,
      page: () => const AdminJobsListScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminJobCreate,
      page: () => const AdminJobCreateScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminJobEdit,
      page: () => const AdminJobEditScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminCandidates,
      page: () => const AdminCandidatesListScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminCandidateDetails,
      page: () => const AdminCandidateDetailsScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminDocumentTypes,
      page: () => const AdminDocumentTypesScreen(),
      binding: AdminBindings(),
    ),
    GetPage(
      name: AppConstants.routeAdminManageAdmins,
      page: () => const AdminManageAdminsScreen(),
      binding: AdminBindings(),
    ),
  ];

  static GetPage unknownRoute = GetPage(
    name: '/not-found',
    page: () => const CandidateLoginScreen(),
  );
}

