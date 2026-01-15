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
  ProfileController? _profileController;
  Widget? _cachedChild;
  AppSideLayout? _cachedLayout; // Cache the layout widget itself
  List<AppNavigationItemModel>? _navigationItems; // Static navigation items
  bool _isUpdatingNavigation = false; // Prevent rapid navigation updates
  
  @override
  void initState() {
    super.initState();
    _profileController = Get.find<ProfileController>();
    _cachedChild = widget.child; // Cache child on first build
    _setupProfileCompletionCheck();
    _setupNavigationItems();
    
    // Listen to profile changes to update navigation when profile loads
    // But only update once, not reactively during input
    // Use a debounce to prevent rapid updates
    ever(_profileController!.profile, (profile) {
      if (profile != null && mounted && !_isUpdatingNavigation) {
        _isUpdatingNavigation = true;
        // Update navigation items once when profile loads
        // Use a delay to batch updates and avoid interrupting user input
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _updateNavigationItems();
            _isUpdatingNavigation = false;
          }
        });
      }
    });
  }
  
  void _setupNavigationItems() {
    // Build navigation items once on init
    _updateNavigationItems();
  }
  
  bool? _lastProfileCompletedStatus;
  
  void _updateNavigationItems() {
    if (_profileController == null) return;
    final isProfileCompleted = _profileController!.isProfileCompleted();
    
    // Only update if completion status actually changed
    if (_lastProfileCompletedStatus == isProfileCompleted) {
      return; // Don't rebuild if nothing changed
    }
    
    _lastProfileCompletedStatus = isProfileCompleted;
    _navigationItems = _buildNavigationItems(isProfileCompleted);
    // Clear cached layout so it rebuilds with new navigation
    _cachedLayout = null;
    // Trigger rebuild to update navigation
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void didUpdateWidget(AppCandidateLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update cached child if it's actually different
    // Use runtimeType and key comparison to avoid false positives
    final oldChildType = oldWidget.child.runtimeType;
    final newChildType = widget.child.runtimeType;
    final oldChildKey = _getWidgetKey(oldWidget.child);
    final newChildKey = _getWidgetKey(widget.child);
    
    // Also check if title, actions, or other properties changed
    final titleChanged = oldWidget.title != widget.title;
    final actionsChanged = oldWidget.actions != widget.actions;
    
    if (oldChildType != newChildType || oldChildKey != newChildKey || titleChanged || actionsChanged) {
      if (oldChildType != newChildType || oldChildKey != newChildKey) {
        _cachedChild = widget.child;
      }
      // Clear cached layout so it will be rebuilt with new values
      _cachedLayout = null;
    }
  }
  
  Key? _getWidgetKey(Widget widget) {
    if (widget is KeyedSubtree) {
      return widget.key;
    }
    // Try to extract key from widget
    return widget.key;
  }
  
  List<AppNavigationItemModel> _buildNavigationItems(bool isProfileCompleted) {
    return [
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
            profileController.profile.value !=
                null && // Only check if profile has loaded
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
      authController = Get.put(
        CandidateAuthController(authRepo),
        permanent: false,
      );
    }
    
    // Use cached child to prevent unnecessary rebuilds
    // The child is only updated in didUpdateWidget when it actually changes
    final childToUse = _cachedChild ?? widget.child;
    
    // CRITICAL: If layout is cached and widget is unchanged, return the EXACT SAME instance
    // to prevent Flutter from disposing the child widget tree
    if (_cachedLayout != null) {
      return _cachedLayout!;
    }
    _cachedLayout = _buildLayout(authController, childToUse);
    return _cachedLayout!;
  }
  
  AppSideLayout _buildLayout(CandidateAuthController authController, Widget child) {
    // Wrap child in RepaintBoundary to prevent unnecessary repaints
    // and use a stable key to preserve widget identity
    final stableChild = RepaintBoundary(
      key: const ValueKey('candidate-layout-child-repaint'),
      child: KeyedSubtree(
        key: const ValueKey('candidate-layout-child'),
        child: child, // Use cached child to prevent recreation
      ),
    );
    
    // Use static navigationItems instead of reactive navigationItemsBuilder
    // This eliminates Obx rebuilds that were causing the form to be disposed
    return AppSideLayout(
      key: const ValueKey('candidate-layout'),
      title: widget.title,
      actions: widget.actions,
      dashboardRoute: AppConstants.routeCandidateDashboard,
      onLogout: () => authController.signOut(),
      navigationItems: _navigationItems ?? _buildNavigationItems(false), // Static navigation items
      child: stableChild, // Use stable child wrapped in RepaintBoundary
    );
  }
}
