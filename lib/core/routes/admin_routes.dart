import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/middleware/auth_middleware.dart';
import 'package:ats/presentation/admin/bindings/admin_bindings.dart';
import 'package:ats/presentation/admin/screens/auth/admin_login_screen.dart';
import 'package:ats/presentation/admin/screens/auth/admin_signup_screen.dart';
import 'package:ats/presentation/admin/screens/auth/admin_forgot_password_screen.dart';
import 'package:ats/presentation/admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:ats/presentation/admin/screens/jobs/admin_jobs_list_screen.dart';
import 'package:ats/presentation/admin/screens/jobs/admin_job_create_screen.dart';
import 'package:ats/presentation/admin/screens/jobs/admin_job_edit_screen.dart';
import 'package:ats/presentation/admin/screens/candidates/admin_candidates_list_screen.dart';
import 'package:ats/presentation/admin/screens/candidates/admin_candidate_details_screen.dart';
import 'package:ats/presentation/admin/screens/document_types/admin_document_types_screen.dart';
import 'package:ats/presentation/admin/screens/admins/admin_manage_admins_screen.dart';

class AdminRoutes {
  static const String initial = AppConstants.routeAdminLogin;

  static List<GetPage> get routes => [
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
        GetPage(
          name: AppConstants.routeAdminForgotPassword,
          page: () => const AdminForgotPasswordScreen(),
          binding: AdminBindings(),
          middlewares: [AuthMiddleware()],
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

  static GetPage get unknownRoute => GetPage(
        name: '/not-found',
        page: () => const AdminLoginScreen(),
      );
}

