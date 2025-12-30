import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobsController>();

    return AppCandidateLayout(
      title: AppTexts.jobs,
      child: Obx(
        () => controller.jobs.isEmpty
            ? AppEmptyState(
                message: AppTexts.noJobsAvailable,
                icon: Iconsax.briefcase,
              )
            : ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: controller.jobs.length,
                itemBuilder: (context, index) {
                  final job = controller.jobs[index];
                  return AppListCard(
                    title: job.title,
                    subtitle: job.description.length > 50
                        ? '${job.description.substring(0, 50)}...'
                        : job.description,
                    icon: Iconsax.briefcase,
                    trailing: controller.hasApplied(job.jobId)
                        ? AppStatusChip(
                            status: 'applied',
                            customText: AppTexts.applied,
                          )
                        : AppButton(
                            backgroundColor: AppColors.primary,
                            text: AppTexts.apply,
                            icon: Iconsax.send_2,
                            onPressed: () {
                              controller.selectJob(job);
                              Get.toNamed(
                                AppConstants.routeCandidateJobDetails,
                              );
                            },
                            isFullWidth: false,
                          ),
                    onTap: () {
                      controller.selectJob(job);
                      Get.toNamed(AppConstants.routeCandidateJobDetails);
                    },
                  );
                },
              ),
      ),
    );
  }
}
