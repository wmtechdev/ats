import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppContentSection extends StatelessWidget {
  final String title;
  final String content;

  const AppContentSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(fontWeight: FontWeight.w500, color: AppColors.success),
        ),
        AppSpacing.vertical(context, 0.01),
        Text(content, style: AppTextStyles.bodyText(context)),
      ],
    );
  }
}
