import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_images/app_images.dart';
import 'package:ats/core/widgets/common/app_navigation_item.dart';
import 'package:ats/core/widgets/common/app_navigation_item_model.dart';
import 'package:ats/core/widgets/common/app_user_profile_section.dart';

class AppSideLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final List<AppNavigationItemModel> navigationItems;
  final VoidCallback onLogout;
  final String? dashboardRoute;

  const AppSideLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    required this.navigationItems,
    required this.onLogout,
    this.dashboardRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppResponsive.isMobile(context);
    final drawerKey = GlobalKey<ScaffoldState>();

    if (isMobile) {
      return Scaffold(
        key: drawerKey,
        backgroundColor: AppColors.lightBackground,
        drawer: _buildDrawer(context),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.menu_1,
              size: AppResponsive.iconSize(context),
              color: AppColors.black,
            ),
            onPressed: () => drawerKey.currentState?.openDrawer(),
          ),
          title: title != null
              ? Text(title!, style: AppTextStyles.heading(context))
              : null,
          actions: actions,
        ),
        body: child,
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Row(
          children: [
            // Fixed Sidebar
            _buildSidebar(context),
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top App Bar with User Profile
                  _buildTopAppBar(context),
                  // Main Content
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSidebar(BuildContext context) {
    final sidebarWidth = AppResponsive.isDesktop(context)
        ? AppResponsive.screenWidth(context) * 0.15
        : AppResponsive.screenWidth(context) * 0.2;

    return Container(
      width: sidebarWidth.clamp(200.0, 300.0),
      color: AppColors.primary,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: AppSpacing.all(context, factor: 1.5),
            child: Image.asset(
              AppImages.appLogo,
              height: AppResponsive.screenHeight(context) * 0.06,
              fit: BoxFit.contain,
            ),
          ),
          Divider(color: AppColors.white),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: navigationItems
                  .map((item) => AppNavigationItem(
                        item: item,
                        dashboardRoute: dashboardRoute,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: AppSpacing.all(context, factor: 1.5),
            child: Image.asset(
              AppImages.appLogo,
              height: AppResponsive.screenHeight(context) * 0.06,
              fit: BoxFit.contain,
            ),
          ),
          Divider(
            color: AppColors.white,
            height: AppResponsive.screenHeight(context) * 0.001,
            thickness: AppResponsive.screenHeight(context) * 0.001,
          ),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: navigationItems
                  .map(
                    (item) => AppNavigationItem(
                      item: item,
                      dashboardRoute: dashboardRoute,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  )
                  .toList(),
            ),
          ),
          // User Profile Section at Bottom
          Divider(
            color: AppColors.white,
            height: AppResponsive.screenHeight(context) * 0.001,
            thickness: AppResponsive.screenHeight(context) * 0.001,
          ),
          AppUserProfileSection(onLogout: onLogout),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    final appBarHeight = AppResponsive.screenHeight(context) * 0.08;

    return Container(
      height: appBarHeight.clamp(60.0, 80.0),
      color: AppColors.primary,
      padding: AppSpacing.symmetric(context, h: 0.03, v: 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTextStyles.heading(
                  context,
                ).copyWith(fontWeight: FontWeight.w500, color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Actions and User Profile
          Row(
            children: [
              if (actions != null) ...actions!,
              AppSpacing.horizontal(context, 0.02),
              AppUserProfileSection(onLogout: onLogout),
            ],
          ),
        ],
      ),
    );
  }
}
