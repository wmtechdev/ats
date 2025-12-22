import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: icon != null
          ? Icon(
              icon,
              size: AppResponsive.iconSize(context),
            )
          : const SizedBox.shrink(),
      label: Text(
        text,
        style: AppTextStyles.buttonText(context),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? AppColors.white,
        padding: AppSpacing.symmetric(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context),
          ),
        ),
      ),
    );

    if (isLoading) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: button,
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }
}

