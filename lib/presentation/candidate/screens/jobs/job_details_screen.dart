import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobsController>();

    return AppCandidateLayout(
      title: AppTexts.jobDetails,
      child: Obx(() {
        final job = controller.selectedJob.value;
        if (job == null) {
          return AppEmptyState(
            message: AppTexts.jobNotFound,
            icon: Iconsax.receipt_search,
          );
        }

        return SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.briefcase,
                    size: AppResponsive.iconSize(context, factor: 1.5),
                    color: AppColors.primary,
                  ),
                  AppSpacing.horizontal(context, 0.02),
                  Expanded(
                    child: Text(
                      job.title,
                      style: AppTextStyles.headline(context),
                    ),
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.03),
              Text(AppTexts.description, style: AppTextStyles.heading(context)),
              AppSpacing.vertical(context, 0.01),
              Text(job.description, style: AppTextStyles.bodyText(context)),
              AppSpacing.vertical(context, 0.03),
              Text(
                AppTexts.requirements,
                style: AppTextStyles.heading(context),
              ),
              AppSpacing.vertical(context, 0.01),
              Container(
                width: double.infinity,
                padding: AppSpacing.all(context),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 5),
                  ),
                ),
                child: Text(
                  job.requirements,
                  style: AppTextStyles.bodyText(context),
                ),
              ),
              AppSpacing.vertical(context, 0.04),
              Obx(
                () => controller.hasApplied(job.jobId)
                    ? Container(
                        padding: AppSpacing.all(context),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radius(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.tick_circle,
                              size: AppResponsive.iconSize(context),
                              color: AppColors.success,
                            ),
                            AppSpacing.horizontal(context, 0.01),
                            Text(
                              AppTexts.alreadyApplied,
                              style: AppTextStyles.bodyText(
                                context,
                              ).copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      )
                    : AppButton(
                        text: AppTexts.applyNow,
                        icon: Iconsax.send_2,
                        onPressed: () => controller.applyToJob(job.jobId),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
