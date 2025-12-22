import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class AppSpacing {
  static EdgeInsets padding(BuildContext context, {double multiplier = 1}) {
    final width = MediaQuery.of(context).size.width;
    double padding;
    if (AppResponsive.isMobile(context)) {
      padding = width * 0.03 * multiplier;
    } else if (AppResponsive.isTablet(context)) {
      padding = width * 0.025 * multiplier;
    } else {
      // Fixed padding for desktop (max 24px)
      padding = (24.0 * multiplier).clamp(8.0, 32.0);
    }
    return EdgeInsets.all(padding);
  }

  static EdgeInsets all(BuildContext context, {double factor = 1}) {
    final width = AppResponsive.screenWidth(context);
    double spacing;
    if (AppResponsive.isMobile(context)) {
      spacing = width * 0.02 * factor;
    } else if (AppResponsive.isTablet(context)) {
      spacing = width * 0.015 * factor;
    } else {
      // Fixed spacing for desktop (max 20px)
      spacing = (20.0 * factor).clamp(4.0, 24.0);
    }
    return EdgeInsets.all(spacing);
  }

  static EdgeInsets symmetric(
    BuildContext context, {
    double h = 0.04,
    double v = 0.02,
  }) {
    final width = AppResponsive.screenWidth(context);
    final height = AppResponsive.screenHeight(context);
    double horizontal, vertical;
    
    if (AppResponsive.isMobile(context)) {
      horizontal = width * h;
      vertical = height * v;
    } else if (AppResponsive.isTablet(context)) {
      horizontal = width * (h * 0.75);
      vertical = height * (v * 0.75);
    } else {
      // Fixed symmetric spacing for desktop
      horizontal = (width * h).clamp(16.0, 48.0);
      vertical = (height * v).clamp(8.0, 24.0);
    }
    
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  static SizedBox vertical(BuildContext context, double factor) {
    final height = AppResponsive.screenHeight(context);
    double spacing;
    if (AppResponsive.isMobile(context)) {
      spacing = height * factor;
    } else if (AppResponsive.isTablet(context)) {
      spacing = height * factor * 0.8;
    } else {
      // For desktop, cap vertical spacing to prevent excessive gaps
      spacing = (height * factor).clamp(8.0, 64.0);
    }
    return SizedBox(height: spacing);
  }

  static SizedBox horizontal(BuildContext context, double factor) {
    final width = AppResponsive.screenWidth(context);
    double spacing;
    if (AppResponsive.isMobile(context)) {
      spacing = width * factor;
    } else if (AppResponsive.isTablet(context)) {
      spacing = width * factor * 0.8;
    } else {
      // For desktop, cap horizontal spacing to prevent excessive gaps
      spacing = (width * factor).clamp(8.0, 64.0);
    }
    return SizedBox(width: spacing);
  }
}
