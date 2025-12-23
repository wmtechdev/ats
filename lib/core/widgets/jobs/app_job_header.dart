import 'package:flutter/material.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/domain/entities/job_entity.dart';

class AppJobHeader extends StatelessWidget {
  final JobEntity job;
  final VoidCallback? onEdit;

  const AppJobHeader({
    super.key,
    required this.job,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                customText: job.status == AppConstants.jobStatusOpen
                    ? AppTexts.open
                    : AppTexts.closed,
              ),
            ],
          ),
        ),
        if (onEdit != null) ...[
          AppSpacing.horizontal(context, 0.02),
          AppActionButton.edit(onPressed: onEdit),
        ],
      ],
    );
  }
}

