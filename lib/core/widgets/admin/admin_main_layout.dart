import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_responsive/app_responsive.dart';
import '../../utils/app_spacing/app_spacing.dart';
import '../../utils/app_styles/app_text_styles.dart';
import 'admin_drawer.dart';
import 'admin_profile_section.dart';
import 'admin_sidebar.dart';

class AdminMainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const AdminMainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.lightGrey,
      drawer: responsive.isDesktop ? null : const AdminDrawer(),
      body: Row(
        children: [
          // Sidebar for Desktop
          if (responsive.isDesktop) const AdminSidebar(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.scaleSize(0.02),
                    vertical: responsive.scaleSize(0.015),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Menu Icon for Mobile/Tablet
                      if (!responsive.isDesktop)
                        IconButton(
                          icon: Icon(
                            Iconsax.menu,
                            color: AppColors.primary,
                            size: responsive.iconSize(24),
                          ),
                          onPressed: () {
                            scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      if (!responsive.isDesktop)
                        SizedBox(width: responsive.scaleSize(0.01)),

                      // Title
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.headline(context).copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Actions
                      if (actions != null) ...actions!,
                      if (actions != null)
                        SizedBox(width: responsive.scaleSize(0.02)),

                      // Profile Section for Desktop
                      if (responsive.isDesktop)
                        const AdminProfileSection(isInDrawer: false),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.padding(context),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
