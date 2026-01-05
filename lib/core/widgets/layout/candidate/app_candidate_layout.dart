import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/candidate_auth_controller.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppCandidateLayout extends StatefulWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const AppCandidateLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  State<AppCandidateLayout> createState() => _AppCandidateLayoutState();
}

class _AppCandidateLayoutState extends State<AppCandidateLayout> {
  @override
  void initState() {
    super.initState();
    _setupProfileCompletionCheck();
  }

  void _setupProfileCompletionCheck() {
    final profileController = Get.find<ProfileController>();
    final currentRoute = Get.currentRoute;
    
    // Only set up redirect check if not on profile screen
    if (currentRoute != AppConstants.routeCandidateProfile) {
      // Watch profile changes and redirect if incomplete
      // Only redirect when profile is loaded (not null) and incomplete
      ever(profileController.profile, (profile) {
        if (mounted && profile != null) {
          // Profile has loaded, check if it's complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && 
                !profileController.isProfileCompleted() && 
                Get.currentRoute != AppConstants.routeCandidateProfile) {
              Get.offNamed(AppConstants.routeCandidateProfile);
              AppSnackbar.show(
                message: 'Please complete your profile to access the app',
                duration: const Duration(seconds: 3),
              );
            }
          });
        }
      });
      
      // Check after a delay to allow profile stream to load
      // Don't redirect if profile is null (still loading), only if it's loaded and incomplete
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && 
            profileController.profile.value != null && // Only check if profile has loaded
            !profileController.isProfileCompleted() && 
            Get.currentRoute != AppConstants.routeCandidateProfile) {
          Get.offNamed(AppConstants.routeCandidateProfile);
          AppSnackbar.show(
            message: 'Please complete your profile to access the app',
            duration: const Duration(seconds: 3),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure CandidateAuthController exists, create it if needed
    CandidateAuthController authController;
    try {
      authController = Get.find<CandidateAuthController>();
    } catch (e) {
      // Controller not found, create it using the repository
      // Get.find will trigger lazy initialization if repository is registered with lazyPut
      final authRepo = Get.find<CandidateAuthRepository>();
      authController = Get.put(CandidateAuthController(authRepo), permanent: false);
    }
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final isProfileCompleted = profileController.isProfileCompleted();
      
      final navigationItems = [
        AppNavigationItemModel(
          title: AppTexts.dashboard,
          icon: Iconsax.home,
          route: AppConstants.routeCandidateDashboard,
          enabled: isProfileCompleted,
        ),
        AppNavigationItemModel(
          title: AppTexts.profile,
          icon: Iconsax.profile_circle,
          route: AppConstants.routeCandidateProfile,
        ),
        AppNavigationItemModel(
          title: AppTexts.jobs,
          icon: Iconsax.briefcase,
          route: AppConstants.routeCandidateJobs,
          enabled: isProfileCompleted,
        ),
        AppNavigationItemModel(
          title: AppTexts.applications,
          icon: Iconsax.document,
          route: AppConstants.routeCandidateApplications,
          enabled: isProfileCompleted,
        ),
        AppNavigationItemModel(
          title: AppTexts.documents,
          icon: Iconsax.folder,
          route: AppConstants.routeCandidateDocuments,
          enabled: isProfileCompleted,
        ),
      ];

      return AppSideLayout(
        title: widget.title,
        actions: widget.actions,
        navigationItems: navigationItems,
        dashboardRoute: AppConstants.routeCandidateDashboard,
        onLogout: () => authController.signOut(),
        child: widget.child,
      );
    });
  }
}

