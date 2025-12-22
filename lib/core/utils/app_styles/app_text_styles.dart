import 'package:ats/core/utils/app_fonts/app_fonts.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle headline(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fontSize;
    if (AppResponsive.isMobile(context)) {
      fontSize = width * 0.08;
    } else if (AppResponsive.isTablet(context)) {
      fontSize = width * 0.05;
    } else {
      fontSize = 48.0; // Fixed size for desktop
    }
    return TextStyle(
      fontSize: fontSize,
      fontFamily: AppFonts.primaryFont,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle heading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fontSize;
    if (AppResponsive.isMobile(context)) {
      fontSize = width * 0.06;
    } else if (AppResponsive.isTablet(context)) {
      fontSize = width * 0.04;
    } else {
      fontSize = 36.0; // Fixed size for desktop
    }
    return TextStyle(
      fontSize: fontSize,
      fontFamily: AppFonts.primaryFont,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle bodyText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fontSize;
    if (AppResponsive.isMobile(context)) {
      fontSize = width * 0.04;
    } else if (AppResponsive.isTablet(context)) {
      fontSize = width * 0.03;
    } else {
      fontSize = 16.0; // Fixed size for desktop
    }
    return TextStyle(
      fontSize: fontSize,
      fontFamily: AppFonts.secondaryFont,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle hintText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fontSize;
    if (AppResponsive.isMobile(context)) {
      fontSize = width * 0.04;
    } else if (AppResponsive.isTablet(context)) {
      fontSize = width * 0.03;
    } else {
      fontSize = 16.0; // Fixed size for desktop
    }
    return TextStyle(
      fontSize: fontSize,
      fontFamily: AppFonts.secondaryFont,
      color: Theme.of(context).hintColor,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double fontSize;
    if (AppResponsive.isMobile(context)) {
      fontSize = width * 0.045;
    } else if (AppResponsive.isTablet(context)) {
      fontSize = width * 0.035;
    } else {
      fontSize = 18.0; // Fixed size for desktop
    }
    return TextStyle(
      fontSize: fontSize,
      fontFamily: AppFonts.secondaryFont,
      color: Colors.white,
    );
  }
}
