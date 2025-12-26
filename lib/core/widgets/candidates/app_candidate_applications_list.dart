import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
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

        return AppListCard(
          key: ValueKey('application_${app.applicationId}'),
          title: jobTitle,
          subtitle: '${AppTexts.status}: ${app.status}',
          icon: Iconsax.briefcase,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppActionButton(
                text: AppTexts.approved,
                onPressed: () => onStatusUpdate(
                  app.applicationId,
                  AppConstants.applicationStatusApproved,
                ),
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
              AppSpacing.horizontal(context, 0.01),
              AppActionButton(
                text: AppTexts.denied,
                onPressed: () => onStatusUpdate(
                  app.applicationId,
                  AppConstants.applicationStatusDenied,
                ),
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
            ],
          ),
          onTap: null,
        );
      },
    );
  }
}

