import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobDetailsScreen extends StatelessWidget {
  const AdminJobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsController = Get.find<AdminJobsController>();
    final documentsController = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.jobDetails,
      child: Obx(() {
        final job = jobsController.selectedJob.value;
        if (job == null) {
          return AppEmptyState(
            message: AppTexts.jobNotFound,
            icon: Iconsax.document,
          );
        }

        final applicationCount = jobsController.getApplicationCount(job.jobId);
        final requiredDocuments = documentsController.documentTypes
            .where((doc) => job.requiredDocumentIds.contains(doc.docTypeId))
            .toList();

        return SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Status and Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppTextStyles.headline(context),
                        ),
                        AppSpacing.vertical(context, 0.01),
                        AppStatusChip(
                          status: job.status,
                          customText: job.status == AppConstants.jobStatusOpen ? 'Open' : 'Closed',
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontal(context, 0.02),
                  IconButton(
                    icon: Icon(
                      Iconsax.edit,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.information,
                    ),
                    onPressed: () {
                      Get.toNamed(AppConstants.routeAdminJobEdit);
                    },
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.03),
              // Description Section
              Text(
                AppTexts.description,
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
                  job.description,
                  style: AppTextStyles.bodyText(context),
                ),
              ),
              AppSpacing.vertical(context, 0.03),
              // Requirements Section
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
              AppSpacing.vertical(context, 0.03),
              // Required Documents Section
              Text(
                'Required Documents',
                style: AppTextStyles.heading(context),
              ),
              AppSpacing.vertical(context, 0.01),
              if (requiredDocuments.isEmpty)
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
                    'No required documents',
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                )
              else
                ...requiredDocuments.map((doc) => Container(
                      margin: EdgeInsets.only(
                        bottom: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      padding: AppSpacing.all(context),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radius(context, factor: 5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.document_text,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.primary,
                          ),
                          AppSpacing.horizontal(context, 0.02),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: AppTextStyles.bodyText(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (doc.description.isNotEmpty)
                                  Text(
                                    doc.description,
                                    style: AppTextStyles.bodyText(context).copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              AppSpacing.vertical(context, 0.03),
              // Statistics Section
              Container(
                padding: AppSpacing.all(context),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.document_download,
                      size: AppResponsive.iconSize(context, factor: 1.5),
                      color: AppColors.primary,
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Text(
                      'Applications: $applicationCount',
                      style: AppTextStyles.heading(context).copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

