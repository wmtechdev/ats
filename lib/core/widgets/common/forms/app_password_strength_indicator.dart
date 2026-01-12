import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_validators/app_password_strength.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppPasswordStrengthIndicator extends StatelessWidget {
  final String? password;
  final bool showLabel;

  const AppPasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password == null || password!.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = PasswordStrengthCalculator.calculateStrength(password);
    final percentage = PasswordStrengthCalculator.getStrengthPercentage(
      password,
    );
    final label = PasswordStrengthCalculator.getStrengthLabel(strength);

    Color strengthColor;
    switch (strength) {
      case PasswordStrength.weak:
        strengthColor = AppColors.error;
        break;
      case PasswordStrength.medium:
        strengthColor = AppColors.warning;
        break;
      case PasswordStrength.strong:
        strengthColor = AppColors.success;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppResponsive.radius(context, factor: 0.5),
                ),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppColors.lightGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  minHeight: AppResponsive.scaleSize(context, 4),
                ),
              ),
            ),
            if (showLabel) ...[
              SizedBox(width: AppResponsive.scaleSize(context, 8)),
              Text(
                label,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                  fontSize: AppResponsive.scaleSize(context, 12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
