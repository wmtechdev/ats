import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppDashboardCard extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppDashboardCard({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        child: Padding(
          padding: AppSpacing.all(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppResponsive.iconSize(context, factor: 2),
                color: iconColor ?? AppColors.primary,
              ),
              if (value != null) ...[
                AppSpacing.vertical(context, 0.02),
                Text(
                  value!,
                  style: AppTextStyles.headline(context),
                ),
              ],
              AppSpacing.vertical(context, value != null ? 0.01 : 0.02),
              Text(
                title,
                style: AppTextStyles.bodyText(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

