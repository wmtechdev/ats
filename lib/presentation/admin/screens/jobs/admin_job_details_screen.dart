import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
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
              AppJobHeader(
                job: job,
                onEdit: () => Get.toNamed(AppConstants.routeAdminJobEdit),
                label: AppTexts.applications,
                value: applicationCount,
              ),
              AppSpacing.vertical(context, 0.02),
              AppContentSection(
                title: AppTexts.description,
                content: job.description,
              ),
              AppSpacing.vertical(context, 0.02),
              AppContentSection(
                title: AppTexts.requirements,
                content: job.requirements,
              ),
              AppSpacing.vertical(context, 0.02),
              AppRequiredDocumentsSection(requiredDocuments: requiredDocuments),
            ],
          ),
        );
      }),
    );
  }
}
