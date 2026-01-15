import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobsListScreen extends StatefulWidget {
  const AdminJobsListScreen({super.key});

  @override
  State<AdminJobsListScreen> createState() => _AdminJobsListScreenState();
}

class _AdminJobsListScreenState extends State<AdminJobsListScreen> {
  late final TextEditingController _searchController;
  late final AdminJobsController _controller;
  Widget? _cachedContent;
  final _searchBarKey = GlobalKey(debugLabel: 'admin-jobs-search-bar');

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminJobsController>();
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
        key: const ValueKey('admin-jobs-content-column'),
        children: [
          Column(
            children: [
              // Search Field and Create Button Row - Use GlobalKey to preserve state
              AppSearchCreateBar(
                key: _searchBarKey,
                searchController: _searchController,
                searchHint: AppTexts.searchJobs,
                createButtonText: AppTexts.createJob,
                createButtonIcon: Iconsax.add,
                onSearchChanged: (value) => _controller.setSearchQuery(value),
                onCreatePressed: () =>
                    Get.toNamed(AppConstants.routeAdminJobCreate),
              ),
              AppSpacing.vertical(context, 0.02),
              // Status Filter Tabs
              Obx(
                () => AppFilterTabs(
                  selectedFilter: _controller.selectedStatusFilter.value,
                  onFilterChanged: (filter) {
                    _controller.setStatusFilter(
                      filter == 'open'
                          ? AppConstants.jobStatusOpen
                          : filter == 'closed'
                          ? AppConstants.jobStatusClosed
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
          // Jobs List
          Expanded(
            child: Obx(() {
              if (_controller.filteredJobs.isEmpty) {
                return AppEmptyState(
                  message: _controller.jobs.isEmpty
                      ? AppTexts.noJobsAvailable
                      : AppTexts.noJobsFound,
                  icon: Iconsax.briefcase,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: _controller.filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = _controller.filteredJobs[index];
                  final applicationCount = _controller.getApplicationCount(
                    job.jobId,
                  );

                  return AppJobCard(
                    job: job,
                    applicationCount: applicationCount,
                    onTap: () {
                      _controller.selectJob(job);
                      Get.toNamed(AppConstants.routeAdminJobDetails);
                    },
                    onEdit: () {
                      _controller.selectJob(job);
                      Get.toNamed(AppConstants.routeAdminJobEdit);
                    },
                    onDelete: () => _showDeleteConfirmation(
                      context,
                      _controller,
                      job.jobId,
                      job.title,
                    ),
                    onStatusToggle: () {
                      final newStatus = job.status == AppConstants.jobStatusOpen
                          ? AppConstants.jobStatusClosed
                          : AppConstants.jobStatusOpen;
                      _controller.changeJobStatus(job.jobId, newStatus);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );

    return AppAdminLayout(
      title: AppTexts.jobs,
      child: _cachedContent!,
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AdminJobsController controller,
    String jobId,
    String jobTitle,
  ) {
    AppAlertDialog.show(
      title: AppTexts.deleteJob,
      subtitle:
          '${AppTexts.deleteJobConfirmation} "$jobTitle"?\n\n${AppTexts.deleteJobWarning}',
      primaryButtonText: AppTexts.delete,
      secondaryButtonText: AppTexts.cancel,
      onPrimaryPressed: () => controller.deleteJob(jobId),
      onSecondaryPressed: () {},
      primaryButtonColor: AppColors.error,
    );
  }
}
