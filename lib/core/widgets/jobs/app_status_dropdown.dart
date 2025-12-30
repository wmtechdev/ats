import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

class AppStatusDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;

  const AppStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: AppTexts.status,
        prefixIcon: Icon(
          Iconsax.info_circle,
          size: AppResponsive.iconSize(context),
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(color: AppColors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: BorderSide(color: AppColors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
      ),
      items: [
        DropdownMenuItem(
          value: AppConstants.jobStatusOpen,
          child: Text(AppTexts.open),
        ),
        DropdownMenuItem(
          value: AppConstants.jobStatusClosed,
          child: Text(AppTexts.closed),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
