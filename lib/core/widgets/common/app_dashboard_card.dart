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
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Gradient? gradient;

  const AppDashboardCard({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackground = gradient != null
        ? null
        : (backgroundColor ?? AppColors.white);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 2),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: cardBackground,
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 2),
            ),
            child: Padding(
              padding: AppSpacing.all(context, factor: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with background circle
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(
                        AppResponsive.screenWidth(context) * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: AppResponsive.iconSize(context, factor: 2),
                        color: iconColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                  if (value != null) ...[
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: AppResponsive.screenHeight(context) * 0.01,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value!,
                            style: AppTextStyles.headline(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor ?? AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.005,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: AppTextStyles.bodyText(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor ?? AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

