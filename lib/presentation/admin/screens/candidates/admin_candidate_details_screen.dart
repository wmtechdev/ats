import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidateDetailsScreen extends StatelessWidget {
  const AdminCandidateDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AdminMainLayout(
      title: AppTexts.candidateDetails,
      child: Obx(() {
        final candidate = controller.selectedCandidate.value;
        if (candidate == null) {
          return AppEmptyState(
            message: AppTexts.candidateNotFound,
            icon: Iconsax.profile_circle,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.sms,
                  size: AppResponsive.iconSize(context),
                  color: AppColors.primary,
                ),
                AppSpacing.horizontal(context, 0.01),
                Text(
                  '${AppTexts.email}: ${candidate.email}',
                  style: AppTextStyles.heading(context),
                ),
              ],
            ),
            AppSpacing.vertical(context, 0.03),
            Text(
              AppTexts.applications,
              style: AppTextStyles.headline(context),
            ),
            AppSpacing.vertical(context, 0.01),
            ...controller.candidateApplications.map((app) => Padding(
                  padding: EdgeInsets.only(
                    bottom: AppResponsive(context).scaleSize(0.015),
                  ),
                  child: AppListCard(
                    key: ValueKey('application_${app.applicationId}'),
                    title: '${AppTexts.applicationStatus} ${app.applicationId}',
                    subtitle: '${AppTexts.status}: ${app.status}',
                    icon: Iconsax.document,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Iconsax.tick_circle,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.success,
                          ),
                          onPressed: () => controller.updateApplicationStatus(
                            applicationId: app.applicationId,
                            status: AppConstants.applicationStatusApproved,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.close_circle,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.error,
                          ),
                          onPressed: () => controller.updateApplicationStatus(
                            applicationId: app.applicationId,
                            status: AppConstants.applicationStatusDenied,
                          ),
                        ),
                      ],
                    ),
                    onTap: null,
                  ),
                )),
            AppSpacing.vertical(context, 0.03),
            Text(
              AppTexts.documents,
              style: AppTextStyles.headline(context),
            ),
            AppSpacing.vertical(context, 0.01),
            ...controller.candidateDocuments.map((doc) => Padding(
                  padding: EdgeInsets.only(
                    bottom: AppResponsive(context).scaleSize(0.015),
                  ),
                  child: AppListCard(
                    key: ValueKey('document_${doc.candidateDocId}'),
                    title: doc.documentName,
                    subtitle: '${AppTexts.status}: ${doc.status}',
                    icon: Iconsax.document_text,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Iconsax.tick_circle,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.success,
                          ),
                          onPressed: () => controller.updateDocumentStatus(
                            candidateDocId: doc.candidateDocId,
                            status: AppConstants.documentStatusApproved,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.close_circle,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.error,
                          ),
                          onPressed: () => controller.updateDocumentStatus(
                            candidateDocId: doc.candidateDocId,
                            status: AppConstants.documentStatusDenied,
                          ),
                        ),
                      ],
                    ),
                    onTap: null,
                  ),
                )),
          ],
        );
      }),
    );
  }
}
