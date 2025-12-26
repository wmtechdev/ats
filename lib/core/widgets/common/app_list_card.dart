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
  final Widget? statusWidget;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool useRowLayout;

  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.statusWidget,
    this.onTap,
    this.iconColor,
    this.useRowLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary,
      margin: AppSpacing.all(context, factor: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
      ),
      child: useRowLayout
          ? _buildRowLayout(context)
          : _buildListTileLayout(context),
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
      child: Padding(
        padding: AppSpacing.all(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Icon, Title, Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: AppResponsive.iconSize(context),
                  color: iconColor ?? AppColors.white,
                ),
                AppSpacing.horizontal(context, 0.02),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (statusWidget != null) ...[
                  AppSpacing.horizontal(context, 0.01),
                  statusWidget!,
                ],
              ],
            ),
            // Subtitle
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              AppSpacing.vertical(context, 0.01),
              Text(
                subtitle!,
                style: AppTextStyles.bodyText(
                  context,
                ).copyWith(color: AppColors.white),
              ),
            ],
            // Trailing (Action Buttons)
            if (trailing != null) ...[
              AppSpacing.vertical(context, 0.01),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListTileLayout(BuildContext context) {
    return ListTile(
      contentPadding: AppSpacing.all(context),
      leading: Icon(
        icon,
        size: AppResponsive.iconSize(context),
        color: iconColor ?? AppColors.white,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyText(
          context,
        ).copyWith(fontWeight: FontWeight.w700, color: AppColors.white),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: EdgeInsets.only(
                top: AppResponsive.screenHeight(context) * 0.01,
                bottom: AppResponsive.screenHeight(context) * 0.01,
              ),
              child: Text(
                subtitle!,
                style: AppTextStyles.bodyText(
                  context,
                ).copyWith(color: AppColors.white),
              ),
            )
          : null,
      trailing: statusWidget ?? trailing,
      onTap: onTap,
    );
  }
}
