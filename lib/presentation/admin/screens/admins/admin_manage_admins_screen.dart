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

class AdminManageAdminsScreen extends StatefulWidget {
  const AdminManageAdminsScreen({super.key});

  @override
  State<AdminManageAdminsScreen> createState() => _AdminManageAdminsScreenState();
}

class _AdminManageAdminsScreenState extends State<AdminManageAdminsScreen> {
  late final TextEditingController _searchController;
  late final AdminManageAdminsController _controller;
  Widget? _cachedContent;
  final _searchBarKey = GlobalKey(debugLabel: 'admin-manage-admins-search-bar');

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminManageAdminsController>();
    _searchController = TextEditingController(text: _controller.searchQuery.value);
    
    ever(_controller.searchQuery, (query) {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cachedContent ??= Builder(
      builder: (context) => Column(
        key: const ValueKey('admin-manage-admins-content-column'),
        children: [
          // Search and Create Section - Use GlobalKey to preserve state
          AppSearchCreateBar(
            key: _searchBarKey,
            searchController: _searchController,
            searchHint: AppTexts.searchAdmins,
            createButtonText: AppTexts.createUser,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => _controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeAdminCreateNewUser);
            },
          ),
          // Admins and Recruiters List
          Expanded(
            child: Obx(() {
              final filteredProfiles = _controller.filteredAdminProfiles
                  .toList();
              final allProfiles = _controller.adminProfiles.toList();

              if (_controller.isLoadingList.value) {
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
                  final isCurrentUser = _controller.isCurrentUser(profile);
                  final isChanging =
                      _controller.isChangingRole[profile.profileId] ?? false;

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
                          customText: isAdmin
                              ? AppTexts.admin
                              : AppTexts.recruiter,
                        ),
                        if (!isCurrentUser) ...[
                          AppActionButton(
                            text: AppTexts.changeRole,
                            onPressed: isChanging
                                ? null
                                : () => _showChangeRoleConfirmation(
                                    context,
                                    _controller,
                                    profile,
                                  ),
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                          ),
                          AppActionButton(
                            text: AppTexts.deleteUser,
                            onPressed:
                                (_controller.isDeletingUser[profile.profileId] ??
                                    false)
                                ? null
                                : () => _showDeleteUserConfirmation(
                                    context,
                                    _controller,
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

    return AppAdminLayout(
      title: AppTexts.manageAdmins,
      child: _cachedContent!,
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
