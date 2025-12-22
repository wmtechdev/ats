import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyText(context),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppColors.lightGrey,
        labelStyle: AppTextStyles.hintText(context),
        hintStyle: AppTextStyles.hintText(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: AppResponsive.iconSize(context),
                color: AppColors.primary,
              )
            : null,
        contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      ),
    );
  }
}
