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
  final int? count;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isFilter;

  const AppStatusChip({
    super.key,
    required this.status,
    this.customText,
    this.showIcon = true,
    this.count,
    this.onTap,
    this.isSelected = false,
    this.isFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = customText ?? status;
    final textColor = _getTextColor(statusColor);

    // For filters: use low opacity when unselected, full opacity when selected
    // For normal use: always use full opacity (old style)
    final backgroundColor = isFilter && !isSelected
        ? statusColor.withValues(alpha: 0.2)
        : statusColor;

    final iconColor = isFilter && !isSelected ? statusColor : textColor;
    final labelColor = isFilter && !isSelected ? statusColor : textColor;
    final countBackgroundColor = isFilter && !isSelected
        ? statusColor.withValues(alpha: 0.2)
        : textColor.withValues(alpha: 0.3);
    final countTextColor = isFilter && !isSelected ? statusColor : textColor;

    Widget chipContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.screenWidth(context) * 0.01,
        vertical: AppResponsive.screenHeight(context) * 0.005,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && statusIcon != null) ...[
            Icon(
              statusIcon,
              size: AppResponsive.iconSize(context),
              color: iconColor,
            ),
            SizedBox(width: AppResponsive.screenWidth(context) * 0.015),
          ],
          Text(
            statusText.toUpperCase(),
            style: AppTextStyles.bodyText(context).copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          if (count != null) ...[
            SizedBox(width: AppResponsive.screenWidth(context) * 0.01),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.screenWidth(context) * 0.008,
                vertical: AppResponsive.screenHeight(context) * 0.002,
              ),
              decoration: BoxDecoration(
                color: countBackgroundColor,
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 3),
                ),
              ),
              child: Text(
                count.toString(),
                style: AppTextStyles.bodyText(context).copyWith(
                  color: countTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: AppTextStyles.bodyText(context).fontSize! * 0.9,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 5),
        ),
        child: chipContent,
      );
    }

    return chipContent;
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == AppConstants.jobStatusOpen ||
        lowerStatus == AppConstants.applicationStatusApproved ||
        lowerStatus == AppConstants.documentStatusApproved) {
      return AppColors.success;
    } else if (lowerStatus == AppConstants.jobStatusClosed ||
        lowerStatus == AppConstants.applicationStatusDenied ||
        lowerStatus == AppConstants.documentStatusDenied ||
        lowerStatus == 'missing') {
      return AppColors.error;
    } else if (lowerStatus == AppConstants.applicationStatusPending ||
        lowerStatus == AppConstants.documentStatusPending) {
      return AppColors.warning;
    } else if (lowerStatus == AppConstants.documentStatusRequested) {
      return AppColors.request;
    } else if (lowerStatus == 'expiry' || lowerStatus == 'expired' ||
        lowerStatus == 'expiring') {
      return AppColors.expiry;
    } else {
      return AppColors.primary;
    }
  }

  IconData? _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    // Requested and expiry statuses should not show icons
    if (lowerStatus == AppConstants.documentStatusRequested ||
        lowerStatus == 'expiry' ||
        lowerStatus == 'expired' ||
        lowerStatus == 'expiring') {
      return null;
    }
    if (lowerStatus == AppConstants.jobStatusOpen ||
        lowerStatus == AppConstants.applicationStatusApproved ||
        lowerStatus == AppConstants.documentStatusApproved) {
      return Iconsax.tick_circle;
    } else if (lowerStatus == AppConstants.jobStatusClosed ||
        lowerStatus == AppConstants.applicationStatusDenied ||
        lowerStatus == AppConstants.documentStatusDenied) {
      return Iconsax.close_circle;
    } else if (lowerStatus == 'missing') {
      return Iconsax.warning_2;
    } else if (lowerStatus == AppConstants.applicationStatusPending ||
        lowerStatus == AppConstants.documentStatusPending) {
      return Iconsax.clock;
    } else {
      return Iconsax.info_circle;
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // Expiry chips always use black text
    if (backgroundColor == AppColors.expiry) {
      return AppColors.black;
    }
    // Calculate luminance to determine if text should be white or black
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.black : AppColors.white;
  }
}
