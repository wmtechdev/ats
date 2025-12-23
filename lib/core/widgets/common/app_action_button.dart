import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: AppSpacing.symmetric(context, h: 0.02, v: 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyText(context).copyWith(
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? AppColors.primary,
        ),
      ),
    );
  }

  // Factory constructors for common action types
  factory AppActionButton.edit({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.edit,
      onPressed: onPressed,
      backgroundColor: AppColors.information,
      foregroundColor: AppColors.white,
    );
  }

  factory AppActionButton.delete({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.delete,
      onPressed: onPressed,
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.white,
    );
  }

  factory AppActionButton.closeJob({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.closeJob,
      onPressed: onPressed,
      backgroundColor: AppColors.warning,
      foregroundColor: AppColors.black,
    );
  }

  factory AppActionButton.openJob({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.openJob,
      onPressed: onPressed,
      backgroundColor: AppColors.success,
      foregroundColor: AppColors.white,
    );
  }
}
