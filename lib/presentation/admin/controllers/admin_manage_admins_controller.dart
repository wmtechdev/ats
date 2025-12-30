import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminManageAdminsController extends GetxController {
  final AdminRepository adminRepository;

  AdminManageAdminsController(this.adminRepository);

  final isLoadingList = false.obs;
  final adminProfiles = <AdminProfileEntity>[].obs;
  final filteredAdminProfiles = <AdminProfileEntity>[].obs;
  final searchQuery = ''.obs;
  final isChangingRole = <String, bool>{}.obs;
  final isDeletingUser = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminProfiles();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredAdminProfiles.value = List.from(adminProfiles);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredAdminProfiles.value = adminProfiles
          .where((profile) =>
              profile.name.toLowerCase().contains(query))
          .toList();
    }
  }


  Future<void> loadAdminProfiles() async {
    isLoadingList.value = true;
    final result = await adminRepository.getAllAdminProfiles();
    result.fold(
      (failure) {
        isLoadingList.value = false;
        // Silently handle errors - don't show error for empty list
      },
      (profiles) {
        adminProfiles.value = profiles;
        _applyFilters();
        isLoadingList.value = false;
      },
    );
  }

  /// Get current user ID
  String? get currentUserId {
    try {
      final authController = Get.find<AdminAuthController>();
      return authController.adminAuthRepository.getCurrentUser()?.userId;
    } catch (e) {
      return null;
    }
  }

  /// Check if profile belongs to current user
  bool isCurrentUser(AdminProfileEntity profile) {
    return profile.userId == currentUserId;
  }

  /// Change role of an admin profile
  Future<void> changeRole(AdminProfileEntity profile) async {
    // Don't allow changing own role
    if (isCurrentUser(profile)) {
      AppSnackbar.error('You cannot change your own role');
      return;
    }

    // Determine new access level (toggle between super_admin and recruiter)
    final newAccessLevel = profile.accessLevel == AppConstants.accessLevelSuperAdmin
        ? AppConstants.accessLevelRecruiter
        : AppConstants.accessLevelSuperAdmin;

    isChangingRole[profile.profileId] = true;

    final result = await adminRepository.updateAdminProfileAccessLevel(
      profileId: profile.profileId,
      accessLevel: newAccessLevel,
    );

    isChangingRole[profile.profileId] = false;

    result.fold(
      (failure) {
        AppSnackbar.error(AppTexts.roleChangeFailed);
      },
      (updatedProfile) {
        // Update the profile in the list
        final index = adminProfiles.indexWhere(
          (p) => p.profileId == profile.profileId,
        );
        if (index != -1) {
          adminProfiles[index] = updatedProfile;
          _applyFilters();
        }
        AppSnackbar.success(AppTexts.roleChanged);
      },
    );
  }

  /// Delete a user (from both Firestore and Authentication)
  Future<void> deleteUser(AdminProfileEntity profile) async {
    // Don't allow deleting own account
    if (isCurrentUser(profile)) {
      AppSnackbar.error('You cannot delete your own account');
      return;
    }

    isDeletingUser[profile.profileId] = true;

    final result = await adminRepository.deleteUser(
      userId: profile.userId,
      profileId: profile.profileId,
    );

    isDeletingUser[profile.profileId] = false;

    result.fold(
      (failure) {
        AppSnackbar.error(failure.message);
      },
      (_) {
        // Remove the profile from the list
        adminProfiles.removeWhere(
          (p) => p.profileId == profile.profileId,
        );
        _applyFilters();
        AppSnackbar.success('User deleted successfully');
      },
    );
  }
}

