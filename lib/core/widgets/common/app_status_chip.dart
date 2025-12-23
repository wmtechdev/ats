import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

class AppStatusChip extends StatelessWidget {
  final String status;
  final String? customText;
  final bool showIcon;

  const AppStatusChip({
    super.key,
    required this.status,
    this.customText,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = customText ?? status;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(context) * 0.025,
        vertical: AppResponsive.screenHeight(context) * 0.008,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context, factor: 2)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && statusIcon != null) ...[
            Icon(
              statusIcon,
              size: AppResponsive.iconSize(context, factor: 0.8),
              color: _getTextColor(statusColor),
            ),
            SizedBox(width: AppResponsive.screenWidth(context) * 0.015),
          ],
          Text(
            statusText.toUpperCase(),
            style: AppTextStyles.bodyText(context).copyWith(
              color: _getTextColor(statusColor),
              fontSize: AppTextStyles.bodyText(context).fontSize! * 0.85,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == AppConstants.jobStatusOpen ||
        lowerStatus == AppConstants.applicationStatusApproved ||
        lowerStatus == AppConstants.documentStatusApproved) {
      return AppColors.success;
    } else if (lowerStatus == AppConstants.jobStatusClosed ||
        lowerStatus == AppConstants.applicationStatusDenied ||
        lowerStatus == AppConstants.documentStatusDenied) {
      return AppColors.error;
    } else if (lowerStatus == AppConstants.applicationStatusPending ||
        lowerStatus == AppConstants.documentStatusPending) {
      return AppColors.warning;
    } else {
      return AppColors.grey;
    }
  }

  IconData? _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == AppConstants.jobStatusOpen ||
        lowerStatus == AppConstants.applicationStatusApproved ||
        lowerStatus == AppConstants.documentStatusApproved) {
      return Iconsax.tick_circle;
    } else if (lowerStatus == AppConstants.jobStatusClosed ||
        lowerStatus == AppConstants.applicationStatusDenied ||
        lowerStatus == AppConstants.documentStatusDenied) {
      return Iconsax.close_circle;
    } else if (lowerStatus == AppConstants.applicationStatusPending ||
        lowerStatus == AppConstants.documentStatusPending) {
      return Iconsax.clock;
    } else {
      return Iconsax.info_circle;
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be white or black
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.black : AppColors.white;
  }
}

