import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/domain/entities/job_entity.dart';

class AppJobCard extends StatelessWidget {
  final JobEntity job;
  final int applicationCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusToggle;

  const AppJobCard({
    super.key,
    required this.job,
    required this.applicationCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: job.title,
      subtitle: _buildSubtitle(context),
      icon: Iconsax.briefcase,
      trailing: null,
      contentBelowSubtitle: Wrap(
        spacing: AppResponsive.screenWidth(context) * 0.01,
        runSpacing: AppResponsive.screenHeight(context) * 0.005,
        children: [
          AppStatusChip(
            status: job.status,
            customText: job.status == AppConstants.jobStatusOpen
                ? AppTexts.open
                : AppTexts.closed,
          ),
          ..._buildTrailingChildren(context),
        ],
      ),
      onTap: onTap,
      useRowLayout: true,
    );
  }

  String _buildSubtitle(BuildContext context) {
    final description = job.description.length > 50
        ? '${job.description.substring(0, 50)}...'
        : job.description;
    return '$description\n${AppTexts.applications}: $applicationCount';
  }

  List<Widget> _buildTrailingChildren(BuildContext context) {
    final children = <Widget>[];
    if (onStatusToggle != null) {
      children.add(
        job.status == AppConstants.jobStatusOpen
            ? AppActionButton.closeJob(onPressed: onStatusToggle)
            : AppActionButton.openJob(onPressed: onStatusToggle),
      );
    }
    if (onEdit != null) {
      children.add(AppActionButton.edit(onPressed: onEdit));
    }
    if (onDelete != null) {
      children.add(AppActionButton.delete(onPressed: onDelete));
    }
    return children;
  }
}
