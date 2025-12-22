import 'package:flutter/material.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppStatusChip extends StatelessWidget {
  final String status;
  final String? customText;

  const AppStatusChip({
    super.key,
    required this.status,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        customText ?? status,
        style: AppTextStyles.bodyText(context).copyWith(
          color: AppColors.white,
          fontSize: AppTextStyles.bodyText(context).fontSize! * 0.9,
        ),
      ),
      backgroundColor: _getStatusColor(status),
      padding: AppSpacing.all(context, factor: 0.3),
    );
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == AppConstants.applicationStatusApproved ||
        lowerStatus == AppConstants.documentStatusApproved) {
      return AppColors.success;
    } else if (lowerStatus == AppConstants.applicationStatusDenied ||
        lowerStatus == AppConstants.documentStatusDenied) {
      return AppColors.error;
    } else if (lowerStatus == AppConstants.applicationStatusPending ||
        lowerStatus == AppConstants.documentStatusPending) {
      return AppColors.warning;
    } else {
      return AppColors.grey;
    }
  }
}

