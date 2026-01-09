import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/presentation/admin/controllers/admin_manage_admins_controller.dart';

class AdminManageAdminsScreen extends StatelessWidget {
  const AdminManageAdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminManageAdminsController>();

    return AppAdminLayout(
      title: AppTexts.manageAdmins,
      child: Column(
        children: [
          // Search and Create Section
          AppSearchCreateBar(
            searchHint: AppTexts.searchAdmins,
            createButtonText: AppTexts.createUser,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeAdminCreateNewUser);
            },
          ),
          // Admins and Recruiters List
          Expanded(
            child: Obx(() {
              final filteredProfiles = controller.filteredAdminProfiles
                  .toList();
              final allProfiles = controller.adminProfiles.toList();

              if (controller.isLoadingList.value) {
                return const Center(child: AppLoadingIndicator());
              }

              if (filteredProfiles.isEmpty) {
                return AppEmptyState(
                  message: allProfiles.isEmpty
                      ? AppTexts.noAdminsAvailable
                      : AppTexts.noAdminsFound,
                  icon: Iconsax.user,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: filteredProfiles.length,
                itemBuilder: (context, index) {
                  final profile = filteredProfiles[index];
                  final isAdmin =
                      profile.accessLevel == AppConstants.accessLevelSuperAdmin;
                  final isCurrentUser = controller.isCurrentUser(profile);
                  final isChanging =
                      controller.isChangingRole[profile.profileId] ?? false;

                  return AppListCard(
                    title: profile.name,
                    subtitle:
                        '${profile.email}\n${AppTexts.role}: ${isAdmin ? AppTexts.admin : AppTexts.recruiter}',
                    icon: Iconsax.user,
                    iconColor: AppColors.primary,
                    trailing: null,
                    contentBelowSubtitle: Wrap(
                      spacing: AppResponsive.screenWidth(context) * 0.01,
                      runSpacing: AppResponsive.screenHeight(context) * 0.005,
                      children: [
                        AppStatusChip(
                          status: isAdmin ? 'admin' : 'recruiter',
                          customText: isAdmin ? AppTexts.admin : AppTexts.recruiter,
                        ),
                        if (!isCurrentUser) ...[
                          AppActionButton(
                            text: AppTexts.changeRole,
                            onPressed: isChanging
                                ? null
                                : () => _showChangeRoleConfirmation(
                                    context,
                                    controller,
                                    profile,
                                  ),
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                          ),
                          AppActionButton(
                            text: AppTexts.deleteUser,
                            onPressed:
                                (controller.isDeletingUser[profile
                                        .profileId] ??
                                    false)
                                ? null
                                : () => _showDeleteUserConfirmation(
                                    context,
                                    controller,
                                    profile,
                                  ),
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.white,
                          ),
                        ],
                      ],
                    ),
                    useRowLayout: true,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleConfirmation(
    BuildContext context,
    AdminManageAdminsController controller,
    AdminProfileEntity profile,
  ) {
    final isAdmin = profile.accessLevel == AppConstants.accessLevelSuperAdmin;
    final newRole = isAdmin ? AppTexts.recruiter : AppTexts.admin;

    AppAlertDialog.show(
      title: AppTexts.changeRole,
      subtitle:
          '${AppTexts.changeRoleConfirmation} "${profile.name}" to $newRole?',
      primaryButtonText: AppTexts.changeRole,
      primaryButtonColor: AppColors.success,
      secondaryButtonText: AppTexts.cancel,
      onPrimaryPressed: () => controller.changeRole(profile),
      onSecondaryPressed: () {},
    );
  }

  void _showDeleteUserConfirmation(
    BuildContext context,
    AdminManageAdminsController controller,
    AdminProfileEntity profile,
  ) {
    AppAlertDialog.show(
      title: AppTexts.deleteUser,
      subtitle:
          '${AppTexts.deleteUserConfirmation} "${profile.name}"? This action cannot be undone.',
      primaryButtonText: AppTexts.deleteUser,
      primaryButtonColor: AppColors.error,
      secondaryButtonText: AppTexts.cancel,
      onPrimaryPressed: () => controller.deleteUser(profile),
      onSecondaryPressed: () {},
    );
  }
}
