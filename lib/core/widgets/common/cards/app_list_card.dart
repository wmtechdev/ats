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
  final Widget? contentBelowSubtitle;
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
    this.contentBelowSubtitle,
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
            // Content below subtitle (status chips, action buttons)
            if (contentBelowSubtitle != null) ...[
              AppSpacing.vertical(context, 0.01),
              contentBelowSubtitle!,
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

  double _getMaxTrailingWidth(BuildContext context) {
    final screenWidth = AppResponsive.screenWidth(context);
    if (AppResponsive.isMobile(context)) {
      // On mobile, allow up to 40% of screen width for trailing
      return screenWidth * 0.4;
    } else if (AppResponsive.isTablet(context)) {
      // On tablet, allow up to 35% of screen width
      return screenWidth * 0.35;
    } else {
      // On desktop, allow up to 30% but cap at 300px for readability
      return (screenWidth * 0.3).clamp(150.0, 300.0);
    }
  }

  Widget _buildListTileLayout(BuildContext context) {
    final trailingWidget = statusWidget ?? trailing;
    final basePadding = AppSpacing.all(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
      child: Padding(
        // Use asymmetric padding: reduce right padding to bring trailing widget closer to edge
        padding: EdgeInsets.only(
          left: basePadding.left,
          top: basePadding.top,
          bottom: basePadding.bottom,
          right: basePadding.right * 0.5, // Reduce right padding by half
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Icon
            Icon(
              icon,
              size: AppResponsive.iconSize(context),
              color: iconColor ?? AppColors.white,
            ),
            AppSpacing.horizontal(context, 0.02),
            // Title and Subtitle (Expanded to take available space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700, color: AppColors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(
                      height: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(color: AppColors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Content below subtitle (status chips, action buttons)
                  if (contentBelowSubtitle != null) ...[
                    SizedBox(
                      height: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    contentBelowSubtitle!,
                  ],
                ],
              ),
            ),
            // Trailing Widget (Aligned to top-right, far right edge)
            if (trailingWidget != null) ...[
              SizedBox(width: basePadding.right * 0.3), // Minimal spacing
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _getMaxTrailingWidth(context),
                ),
                child: trailingWidget,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
