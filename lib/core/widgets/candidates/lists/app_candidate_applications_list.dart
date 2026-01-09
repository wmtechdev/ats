import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppCandidateApplicationsList extends StatelessWidget {
  final List<ApplicationEntity> applications;
  final Map<String, String> jobTitles; // jobId -> jobTitle
  final Function(String applicationId, String status) onStatusUpdate;

  const AppCandidateApplicationsList({
    super.key,
    required this.applications,
    required this.jobTitles,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return AppEmptyState(
        message: AppTexts.noApplicationsYet,
        icon: Iconsax.document,
      );
    }

    return ListView.builder(
      padding: AppSpacing.padding(context),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        final jobTitle = jobTitles[app.jobId] ?? AppTexts.unknownJob;
        final isPending = app.status == AppConstants.applicationStatusPending;
        final isApproved = app.status == AppConstants.applicationStatusApproved;
        final isDenied = app.status == AppConstants.applicationStatusDenied;

        return AppListCard(
          key: ValueKey('application_${app.applicationId}'),
          title: jobTitle,
          subtitle: '${AppTexts.status}: ${app.status}',
          icon: Iconsax.briefcase,
          trailing: null,
          contentBelowSubtitle: Wrap(
            spacing: AppResponsive.screenWidth(context) * 0.01,
            runSpacing: AppResponsive.screenHeight(context) * 0.005,
            children: [
              // Show only status chip when application is approved
              if (isApproved) AppStatusChip(status: app.status),
              // Show approve/deny buttons only when application is pending
              if (isPending) ...[
                AppActionButton(
                  text: AppTexts.approve,
                  onPressed: () => onStatusUpdate(
                    app.applicationId,
                    AppConstants.applicationStatusApproved,
                  ),
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                ),
                AppActionButton(
                  text: AppTexts.deny,
                  onPressed: () => onStatusUpdate(
                    app.applicationId,
                    AppConstants.applicationStatusDenied,
                  ),
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
              ],
              // Show status chip when application is denied (no buttons for admin)
              if (isDenied) AppStatusChip(status: app.status),
            ],
          ),
          onTap: null,
        );
      },
    );
  }
}
