import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_responsive/app_responsive.dart';
import '../../utils/app_styles/app_text_styles.dart';

class AdminNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback? onTap;

  const AdminNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return InkWell(
      onTap: onTap ??
          () {
            Get.offAllNamed(route);
          },
      hoverColor: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(responsive.radius(12)),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: responsive.scaleSize(0.01),
          vertical: responsive.scaleSize(0.005),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.scaleSize(0.015),
          vertical: responsive.scaleSize(0.012),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              size: responsive.iconSize(24),
            ),
            SizedBox(width: responsive.scaleSize(0.01)),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isActive)
              Container(
                width: responsive.scaleSize(0.004),
                height: responsive.scaleSize(0.025),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(responsive.radius(2)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
