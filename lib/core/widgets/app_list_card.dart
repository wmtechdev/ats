import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.all(context, factor: 0.5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context),
        ),
      ),
      child: ListTile(
        contentPadding: AppSpacing.all(context),
        leading: Icon(
          icon,
          size: AppResponsive.iconSize(context, factor: 1.5),
          color: iconColor ?? AppColors.primary,
        ),
        title: Text(
          title,
          style: AppTextStyles.heading(context),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: EdgeInsets.only(
                  top: AppResponsive.screenHeight(context) * 0.01,
                  bottom: AppResponsive.screenHeight(context) * 0.01,
                ),
                child: Text(
                  subtitle!,
                  style: AppTextStyles.bodyText(context),
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

