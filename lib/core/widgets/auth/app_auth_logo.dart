import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_images/app_images.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppAuthLogo extends StatelessWidget {
  const AppAuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final logoSize = AppResponsive.isDesktop(context)
        ? 200.0
        : AppResponsive.isTablet(context)
            ? 180.0
            : 160.0;

    return Center(
      child: Image.asset(
        AppImages.appLogo,
        width: logoSize,
        height: logoSize/2,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildLogoFallback(
          context,
          logoSize,
        ),
      ),
    );
  }

  Widget _buildLogoFallback(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 2),
        ),
      ),
      child: Icon(
        Icons.business_center,
        size: size * 0.5,
        color: AppColors.primary,
      ),
    );
  }
}

