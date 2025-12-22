import 'package:flutter/material.dart';

class AppResponsive {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) => screenWidth(context) < 600;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 1024;

  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1024;

  static double scaleSize(BuildContext context, double size) {
    final width = screenWidth(context);
    if (isMobile(context)) {
      return size * (width / 375);
    } else if (isTablet(context)) {
      return size * (width / 768);
    } else {
      // For desktop, cap the scaling to prevent oversized elements
      return size * (1024 / 768).clamp(1.0, 1.5);
    }
  }

  static double iconSize(BuildContext context, {double factor = 1}) {
    final width = screenWidth(context);
    if (isMobile(context)) {
      return width * 0.05 * factor;
    } else if (isTablet(context)) {
      return width * 0.03 * factor;
    } else {
      // Fixed icon size for desktop
      return 24.0 * factor;
    }
  }

  static double radius(BuildContext context, {double factor = 1}) {
    final width = screenWidth(context);
    if (isMobile(context)) {
      return width * 0.02 * factor;
    } else if (isTablet(context)) {
      return width * 0.015 * factor;
    } else {
      // Fixed radius for desktop
      return 12.0 * factor;
    }
  }
}
