import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/jobs/app_content_section.dart';
import 'package:ats/core/widgets/jobs/app_required_documents_list.dart';
import 'package:ats/core/widgets/common/app_info_message.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsController = Get.find<JobsController>();
    final documentsController = Get.find<DocumentsController>();

    return AppCandidateLayout(
      title: AppTexts.jobDetails,
      child: Obx(() {
        final job = jobsController.selectedJob.value;
        if (job == null) {
          return AppEmptyState(
            message: AppTexts.jobNotFound,
            icon: Iconsax.receipt_search,
          );
        }

        final requiredDocIds = job.requiredDocumentIds;
        final hasAllDocuments = documentsController.hasAllRequiredDocuments(
          requiredDocIds,
        );

        return SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.briefcase,
                    size: AppResponsive.iconSize(context),
                    color: AppColors.primary,
                  ),
                  AppSpacing.horizontal(context, 0.01),
                  Expanded(
                    child: Text(
                      job.title,
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.03),
              AppContentSection(
                title: AppTexts.description,
                content: job.description,
              ),
              AppSpacing.vertical(context, 0.03),
              AppContentSection(
                title: AppTexts.requirements,
                content: job.requirements,
              ),
              // Required Documents Section
              if (requiredDocIds.isNotEmpty) ...[
                AppSpacing.vertical(context, 0.03),
                Text(
                  AppTexts.requiredDocuments,
                  style: AppTextStyles.bodyText(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                AppSpacing.vertical(context, 0.01),
                AppRequiredDocumentsList(
                  requiredDocumentIds: requiredDocIds,
                  documentTypesMap: {
                    for (var docId in requiredDocIds)
                      if (documentsController.getDocumentTypeById(docId) !=
                          null)
                        docId: documentsController.getDocumentTypeById(docId)!,
                  },
                  hasDocumentMap: {
                    for (var docId in requiredDocIds)
                      docId: documentsController.hasDocument(docId),
                  },
                ),
                // Message about missing documents
                AppSpacing.vertical(context, 0.02),
                if (!hasAllDocuments)
                  AppInfoMessage(
                    message: AppTexts.uploadRequiredDocuments,
                    type: AppInfoMessageType.error,
                    action: TextButton.icon(
                      onPressed: () {
                        Get.toNamed(AppConstants.routeCandidateDocuments);
                      },
                      icon: Icon(
                        Iconsax.document_text,
                        size: AppResponsive.iconSize(context),
                        color: AppColors.primary,
                      ),
                      label: Text(
                        AppTexts.goToDocuments,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  AppInfoMessage(
                    message: AppTexts.allDocumentsUploaded,
                    type: AppInfoMessageType.success,
                  ),
              ],
              AppSpacing.vertical(context, 0.04),
              Obx(
                () => jobsController.hasApplied(job.jobId)
                    ? AppInfoMessage(
                        message: AppTexts.alreadyApplied,
                        type: AppInfoMessageType.success,
                      )
                    : AppButton(
                        text: AppTexts.applyNow,
                        icon: Iconsax.send_2,
                        onPressed: hasAllDocuments
                            ? () => jobsController.applyToJob(job.jobId)
                            : null,
                        backgroundColor: hasAllDocuments
                            ? null
                            : AppColors.grey,
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
