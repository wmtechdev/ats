import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

enum AppInfoMessageType {
  success,
  error,
  info,
  warning,
}

class AppInfoMessage extends StatelessWidget {
  final String message;
  final AppInfoMessageType type;
  final IconData? icon;
  final Widget? action;

  const AppInfoMessage({
    super.key,
    required this.message,
    this.type = AppInfoMessageType.info,
    this.icon,
    this.action,
  });

  Color get _backgroundColor {
    switch (type) {
      case AppInfoMessageType.success:
        return AppColors.success;
      case AppInfoMessageType.error:
        return AppColors.error;
      case AppInfoMessageType.warning:
        return AppColors.warning;
      case AppInfoMessageType.info:
        return AppColors.primary;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case AppInfoMessageType.success:
        return Iconsax.tick_circle;
      case AppInfoMessageType.error:
        return Iconsax.info_circle;
      case AppInfoMessageType.warning:
        return Iconsax.warning_2;
      case AppInfoMessageType.info:
        return Iconsax.info_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.all(context),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 5),
        ),
        border: type == AppInfoMessageType.error
            ? Border.all(
                color: _backgroundColor.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? _defaultIcon,
            size: AppResponsive.iconSize(context),
            color: _backgroundColor,
          ),
          AppSpacing.horizontal(context, 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: _backgroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (action != null) ...[
                  AppSpacing.vertical(context, 0.01),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

