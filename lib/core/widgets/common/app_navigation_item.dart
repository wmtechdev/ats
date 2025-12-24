import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/widgets/common/app_navigation_item_model.dart';

class AppNavigationItem extends StatelessWidget {
  final AppNavigationItemModel item;
  final VoidCallback? onTap;
  final String? dashboardRoute;

  const AppNavigationItem({
    super.key,
    required this.item,
    this.onTap,
    this.dashboardRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Check current route - GetX rebuilds widgets on navigation
    final currentRoute = Get.currentRoute;
    // Check if current route matches exactly or starts with the item route
    // This allows sub-routes to highlight the parent navigation item
    final isCurrentlyActive =
        currentRoute == item.route ||
        (currentRoute.startsWith(item.route) &&
            currentRoute.length > item.route.length &&
            currentRoute[item.route.length] == '/');

    final isEnabled = item.enabled;
    
    return InkWell(
      onTap: isEnabled ? () {
        if (onTap != null) {
          onTap!();
        }
        if (Get.currentRoute != item.route) {
          // If dashboard route is provided and we're not going to dashboard,
          // use offNamedUntil to keep dashboard in stack for back navigation
          if (dashboardRoute != null &&
              item.route != dashboardRoute &&
              currentRoute != dashboardRoute) {
            Get.offNamedUntil(
              item.route,
              (route) => route.settings.name == dashboardRoute,
            );
          } else {
            // For dashboard or if no dashboard route specified, use regular navigation
            Get.toNamed(item.route);
          }
        }
      } : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          margin: AppSpacing.all(context, factor: 0.1).copyWith(right: 0),
          padding: AppSpacing.symmetric(context, h: 0.02, v: 0.01),
          decoration: BoxDecoration(
            color: isCurrentlyActive ? AppColors.secondary : Colors.transparent,
            borderRadius: isCurrentlyActive
                ? BorderRadius.only(
                    topLeft: Radius.circular(
                      AppResponsive.radius(context, factor: 5),
                    ),
                    bottomLeft: Radius.circular(
                      AppResponsive.radius(context, factor: 5),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: AppResponsive.iconSize(context, factor: 1.2),
                color: isCurrentlyActive 
                    ? AppColors.white 
                    : (isEnabled ? AppColors.secondary : AppColors.white),
              ),
              AppSpacing.horizontal(context, 0.01),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: isCurrentlyActive
                        ? AppColors.white
                        : (isEnabled ? AppColors.secondary : AppColors.white),
                    fontWeight: isCurrentlyActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
