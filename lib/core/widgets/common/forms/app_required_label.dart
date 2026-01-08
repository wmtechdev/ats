import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

/// Widget for displaying a label with a red asterisk for required fields
class AppRequiredLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AppRequiredLabel({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ??
        AppTextStyles.bodyText(context).copyWith(fontWeight: FontWeight.w500);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text),
          TextSpan(
            text: ' *',
            style: baseStyle.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
