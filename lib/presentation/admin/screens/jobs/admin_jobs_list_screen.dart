import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobsListScreen extends StatelessWidget {
  const AdminJobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminJobsController>();

    return AppAdminLayout(
      title: AppTexts.jobs,
      child: Column(
        children: [
          // Filters Section
          Container(
            padding: AppSpacing.padding(context),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field and Create Button Row
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hintText: 'Search jobs by title or description...',
                        prefixIcon: Iconsax.search_normal,
                        onChanged: (value) => controller.setSearchQuery(value),
                      ),
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    AppButton(
                      text: AppTexts.createJob,
                      icon: Iconsax.add,
                      onPressed: () => Get.toNamed(AppConstants.routeAdminJobCreate),
                      isFullWidth: false,
                    ),
                  ],
                ),
                AppSpacing.vertical(context, 0.02),
                // Status Filter Tabs
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterTab(
                        context: context,
                        label: 'All',
                        isSelected: controller.selectedStatusFilter.value == null,
                        onTap: () => controller.setStatusFilter(null),
                      ),
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Expanded(
                      child: _buildFilterTab(
                        context: context,
                        label: 'Open',
                        isSelected: controller.selectedStatusFilter.value == AppConstants.jobStatusOpen,
                        onTap: () => controller.setStatusFilter(AppConstants.jobStatusOpen),
                      ),
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Expanded(
                      child: _buildFilterTab(
                        context: context,
                        label: 'Closed',
                        isSelected: controller.selectedStatusFilter.value == AppConstants.jobStatusClosed,
                        onTap: () => controller.setStatusFilter(AppConstants.jobStatusClosed),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Jobs List
          Expanded(
            child: Obx(() {
              if (controller.filteredJobs.isEmpty) {
                return AppEmptyState(
                  message: controller.jobs.isEmpty
                      ? AppTexts.noJobsAvailable
                      : 'No jobs found matching your filters',
                  icon: Iconsax.briefcase,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: controller.filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = controller.filteredJobs[index];
                  final applicationCount = controller.getApplicationCount(job.jobId);

                  return AppListCard(
                    title: job.title,
                    subtitle: '${job.description.length > 50 ? job.description.substring(0, 50) + '...' : job.description}\n'
                        'Applications: $applicationCount',
                    icon: Iconsax.briefcase,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Chip
                        AppStatusChip(
                          status: job.status,
                          customText: job.status == AppConstants.jobStatusOpen ? 'Open' : 'Closed',
                        ),
                        AppSpacing.horizontal(context, 0.01),
                        // Status Toggle Button
                        IconButton(
                          icon: Icon(
                            job.status == AppConstants.jobStatusOpen
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                            size: AppResponsive.iconSize(context),
                            color: job.status == AppConstants.jobStatusOpen
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                          tooltip: job.status == AppConstants.jobStatusOpen
                              ? 'Close Job'
                              : 'Open Job',
                          onPressed: () {
                            final newStatus = job.status == AppConstants.jobStatusOpen
                                ? AppConstants.jobStatusClosed
                                : AppConstants.jobStatusOpen;
                            controller.changeJobStatus(job.jobId, newStatus);
                          },
                        ),
                        AppSpacing.horizontal(context, 0.01),
                        // Edit Button
                        IconButton(
                          icon: Icon(
                            Iconsax.edit,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.information,
                          ),
                          onPressed: () {
                            controller.selectJob(job);
                            Get.toNamed(AppConstants.routeAdminJobEdit);
                          },
                        ),
                        AppSpacing.horizontal(context, 0.01),
                        // Delete Button
                        IconButton(
                          icon: Icon(
                            Iconsax.trash,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.error,
                          ),
                          onPressed: () => _showDeleteConfirmation(context, controller, job.jobId, job.title),
                        ),
                      ],
                    ),
                    onTap: () {
                      controller.selectJob(job);
                      Get.toNamed(AppConstants.routeAdminJobDetails);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.02, v: 0.015),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.grey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AdminJobsController controller,
    String jobId,
    String jobTitle,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Job'),
        content: Text('Are you sure you want to delete "$jobTitle"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteJob(jobId);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppTexts.delete),
          ),
        ],
      ),
    );
  }
}
