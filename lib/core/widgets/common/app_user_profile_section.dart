import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/admin_auth_repository.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';

class AppUserProfileSection extends StatelessWidget {
  final VoidCallback onLogout;

  const AppUserProfileSection({super.key, required this.onLogout});

  /// Get user name based on role
  String _getUserName() {
    // Try admin/recruiter first
    if (Get.isRegistered<AdminAuthController>()) {
      try {
        final adminController = Get.find<AdminAuthController>();
        final adminProfile = adminController.currentAdminProfile.value;
        if (adminProfile != null && adminProfile.name.isNotEmpty) {
          return adminProfile.name;
        }
      } catch (e) {
        // Controller not found or not initialized, continue to candidate check
      }
    }

    // Try candidate
    if (Get.isRegistered<ProfileController>()) {
      try {
        final profileController = Get.find<ProfileController>();
        final candidateProfile = profileController.profile.value;
        if (candidateProfile != null) {
          final firstName = candidateProfile.firstName.trim();
          final lastName = candidateProfile.lastName.trim();
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            return '$firstName $lastName'.trim();
          }
        }
      } catch (e) {
        // Controller not found, continue to fallback
      }
    }

    // Fallback: try to get from auth repository
    UserEntity? currentUser;
    if (Get.isRegistered<CandidateAuthRepository>()) {
      try {
        final authRepo = Get.find<CandidateAuthRepository>();
        currentUser = authRepo.getCurrentUser();
      } catch (e) {
        // Repository not found
      }
    } else if (Get.isRegistered<AdminAuthRepository>()) {
      try {
        final authRepo = Get.find<AdminAuthRepository>();
        currentUser = authRepo.getCurrentUser();
      } catch (e) {
        // Repository not found
      }
    }

    if (currentUser != null && currentUser.email.isNotEmpty) {
      return currentUser.email.split('@').first;
    }

    return AppTexts.admin; // Final fallback
  }

  /// Get user role display text
  String _getUserRole() {
    // Check if admin/recruiter
    if (Get.isRegistered<AdminAuthController>()) {
      try {
        final adminController = Get.find<AdminAuthController>();
        final adminProfile = adminController.currentAdminProfile.value;
        if (adminProfile != null) {
          // Map access level to display role
          if (adminProfile.accessLevel == AppConstants.accessLevelSuperAdmin) {
            return AppTexts.admin;
          } else if (adminProfile.accessLevel == AppConstants.accessLevelRecruiter) {
            return AppTexts.recruiter;
          }
        }
      } catch (e) {
        // Controller not found, continue to candidate check
      }
    }

    // Check if candidate
    if (Get.isRegistered<CandidateAuthRepository>()) {
      try {
        final authRepo = Get.find<CandidateAuthRepository>();
        final currentUser = authRepo.getCurrentUser();
        if (currentUser != null && currentUser.role == AppConstants.roleCandidate) {
          return AppTexts.candidate;
        }
      } catch (e) {
        // Repository not found
      }
    }

    // Fallback
    return AppTexts.admin;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppResponsive.isMobile(context);

    // Use Obx to make it reactive to profile changes
    return Obx(() {
      final userName = _getUserName();
      final userRole = _getUserRole();

      if (isMobile) {
      // Mobile: Profile section at bottom of drawer
      return Container(
        padding: AppSpacing.all(context, factor: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Info Row
            Row(
              children: [
                // Name and Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole,
                        style: AppTextStyles.hintText(context).copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: AppResponsive.screenWidth(context) * 0.025,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Logout Button
                IconButton(
                  icon: Icon(
                    Iconsax.logout,
                    size: AppResponsive.iconSize(context),
                    color: AppColors.white,
                  ),
                  onPressed: onLogout,
                  tooltip: AppTexts.logout,
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Desktop: Profile section at top right
      return Row(
        children: [
          // Name and Role
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: AppTextStyles.bodyText(
                  context,
                ).copyWith(fontWeight: FontWeight.w600, color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userRole,
                style: AppTextStyles.hintText(context).copyWith(
                  fontSize: AppResponsive.screenWidth(context) * 0.01,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          AppSpacing.horizontal(context, 0.01),
          // Logout Button
          IconButton(
            icon: Icon(
              Iconsax.logout,
              size: AppResponsive.iconSize(context),
              color: AppColors.white,
            ),
            onPressed: onLogout,
            tooltip: AppTexts.logout,
          ),
        ],
      );
      }
    });
  }
}
