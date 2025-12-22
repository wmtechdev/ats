import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppErrorMessage extends StatelessWidget {
  final String message;

  const AppErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: AppSpacing.all(context),
      child: Text(
        message,
        style: AppTextStyles.bodyText(context).copyWith(
          color: AppColors.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

