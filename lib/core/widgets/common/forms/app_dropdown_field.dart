import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/common/forms/app_required_label.dart';

class AppDropDownField<T> extends StatelessWidget {
  final T? value;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String? errorText;
  final bool showLabelAbove;

  const AppDropDownField({
    super.key,
    this.value,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.errorText,
    this.showLabelAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = AppSpacing.symmetric(context, h: 0.04, v: 0.02);
    final contentPadding = prefixIcon == null
        ? EdgeInsets.only(
            left: defaultPadding.horizontal * 0.1,
            right: defaultPadding.horizontal,
          )
        : defaultPadding;

    final dropdown = DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: showLabelAbove ? null : labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: AppResponsive.iconSize(context),
                color: AppColors.primary,
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 1.5),
          ),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: contentPadding,
        errorText: errorText,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: AppTextStyles.bodyText(context),
    );

    if (showLabelAbove && labelText != null && labelText!.isNotEmpty) {
      final isRequired = labelText!.endsWith('(*)');
      final cleanLabelText = isRequired
          ? labelText!.substring(0, labelText!.length - 3)
          : labelText!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          isRequired
              ? AppRequiredLabel(text: cleanLabelText)
              : Text(
                  cleanLabelText,
                  style: AppTextStyles.bodyText(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
          dropdown,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [dropdown],
    );
  }
}
