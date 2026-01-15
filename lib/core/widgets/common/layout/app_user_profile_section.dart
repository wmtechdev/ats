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

  @override
  Widget build(BuildContext context) {
    final isMobile = AppResponsive.isMobile(context);

    // Check if we have reactive controllers available
    final hasAdminController = Get.isRegistered<AdminAuthController>();
    final hasProfileController = Get.isRegistered<ProfileController>();
    
    // Only use Obx if we have controllers with observables to track
    if (hasAdminController || hasProfileController) {
      return Obx(() {
        String userName = AppTexts.admin;
        String userRole = AppTexts.admin;
        
        // Try admin/recruiter first - access observable directly
        if (hasAdminController) {
          try {
            final adminController = Get.find<AdminAuthController>();
            // Access observable directly - GetX will track this
            final adminProfile = adminController.currentAdminProfile.value;
            if (adminProfile != null && adminProfile.name.isNotEmpty) {
              userName = adminProfile.name;
              // Map access level to display role
              if (adminProfile.accessLevel == AppConstants.accessLevelSuperAdmin) {
                userRole = AppTexts.admin;
              } else if (adminProfile.accessLevel == AppConstants.accessLevelRecruiter) {
                userRole = AppTexts.recruiter;
              } else {
                userRole = AppTexts.admin;
              }
              
              return _buildProfileWidget(context, isMobile, userName, userRole);
            }
          } catch (e) {
            // Controller not found or being recreated, continue to candidate check
          }
        }

        // Try candidate - access observable directly
        if (hasProfileController) {
          try {
            final profileController = Get.find<ProfileController>();
            // Access observable directly - GetX will track this
            final candidateProfile = profileController.profile.value;
            if (candidateProfile != null) {
              final firstName = candidateProfile.firstName.trim();
              final lastName = candidateProfile.lastName.trim();
              if (firstName.isNotEmpty || lastName.isNotEmpty) {
                userName = '$firstName $lastName'.trim();
                userRole = AppTexts.candidate;
                
                return _buildProfileWidget(context, isMobile, userName, userRole);
              }
            }
          } catch (e) {
            // Controller not found or being recreated, continue to fallback
          }
        }

        // Fallback: try to get from auth repository (non-reactive)
        userName = _getFallbackUserName();
        userRole = _getFallbackUserRole();
        
        return _buildProfileWidget(context, isMobile, userName, userRole);
      });
    } else {
      // No reactive controllers available, use non-reactive fallback
      final userName = _getFallbackUserName();
      final userRole = _getFallbackUserRole();
      return _buildProfileWidget(context, isMobile, userName, userRole);
    }
  }
  
  String _getFallbackUserName() {
    // Try to get from auth repository (non-reactive)
    try {
      UserEntity? currentUser;
      if (Get.isRegistered<CandidateAuthRepository>()) {
        final authRepo = Get.find<CandidateAuthRepository>();
        currentUser = authRepo.getCurrentUser();
      } else if (Get.isRegistered<AdminAuthRepository>()) {
        final authRepo = Get.find<AdminAuthRepository>();
        currentUser = authRepo.getCurrentUser();
      }

      if (currentUser != null && currentUser.email.isNotEmpty) {
        return currentUser.email.split('@').first;
      }
    } catch (e) {
      // Repositories not found
    }
    return AppTexts.admin;
  }
  
  String _getFallbackUserRole() {
    // Try to get from auth repository (non-reactive)
    try {
      UserEntity? currentUser;
      if (Get.isRegistered<CandidateAuthRepository>()) {
        final authRepo = Get.find<CandidateAuthRepository>();
        currentUser = authRepo.getCurrentUser();
        if (currentUser != null && currentUser.role == AppConstants.roleCandidate) {
          return AppTexts.candidate;
        }
      } else if (Get.isRegistered<AdminAuthRepository>()) {
        final authRepo = Get.find<AdminAuthRepository>();
        currentUser = authRepo.getCurrentUser();
      }
    } catch (e) {
      // Repositories not found
    }
    return AppTexts.admin;
  }
  
  Widget _buildProfileWidget(BuildContext context, bool isMobile, String userName, String userRole) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and Role
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userRole,
                  style: AppTextStyles.hintText(context).copyWith(
                    fontSize: AppResponsive.screenWidth(context) * 0.01,
                    color: AppColors.white.withValues(alpha: 0.8),
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
  }
}
