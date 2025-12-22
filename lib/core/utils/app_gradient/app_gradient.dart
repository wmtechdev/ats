import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// App Gradient Extension
/// Provides reusable gradient decoration extension
extension AppGradientExtension on BoxDecoration {
  /// Apply app gradient to BoxDecoration
  /// Returns a new BoxDecoration with gradient from primary to secondary color
  BoxDecoration withAppGradient() {
    return copyWith(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [AppColors.secondary, AppColors.primary, AppColors.secondary],
      ),
    );
  }
}
