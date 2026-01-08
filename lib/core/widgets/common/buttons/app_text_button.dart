import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final IconData? icon;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: AppResponsive.iconSize(context),
          color: textColor ?? AppColors.primary,
        ),
        label: Text(
          text,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(color: textColor ?? AppColors.primary),
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.bodyText(
          context,
        ).copyWith(color: textColor ?? AppColors.primary),
      ),
    );
  }
}
