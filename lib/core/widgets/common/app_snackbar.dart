import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_images/app_images.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppSnackbar {
  AppSnackbar._();

  /// Shows a custom snackbar with logo and message
  ///
  /// [message] - The message to display
  /// [title] - Optional title (not displayed but required by Get.snackbar)
  /// [duration] - How long the snackbar should be visible
  /// [snackPosition] - Position of the snackbar (default: BOTTOM)
  static void show({
    required String message,
    String title = '',
    Duration? duration,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    final context = Get.context!;
    Get.snackbar(
      title,
      '',
      messageText: _AppSnackbarContent(message: message),
      titleText: const SizedBox.shrink(),
      backgroundColor: AppColors.secondary,
      snackPosition: snackPosition,
      duration: duration ?? const Duration(seconds: 3),
      margin: EdgeInsets.symmetric(
        horizontal: AppResponsive.isMobile(context)
            ? AppResponsive.screenWidth(context) * 0.05
            : AppResponsive.isTablet(context)
            ? AppResponsive.screenWidth(context) * 0.15
            : AppResponsive.screenWidth(context) * 0.25,
        vertical: 16,
      ),
      borderRadius: AppResponsive.radius(context),
      padding: AppSpacing.symmetric(context, h: 0.02, v: 0.01),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      mainButton: null,
      onTap: (_) => Get.back(),
      shouldIconPulse: false,
      icon: null,
      showProgressIndicator: false,
      maxWidth: AppResponsive.isDesktop(context)
          ? 600
          : AppResponsive.isTablet(context)
          ? 500
          : double.infinity,
      snackStyle: SnackStyle.FLOATING,
      barBlur: 0,
      overlayBlur: 0,
    );
  }

  /// Shows a success snackbar
  static void success(String message) {
    show(message: message);
  }

  /// Shows an error snackbar
  static void error(String message) {
    show(message: message);
  }

  /// Shows an info snackbar
  static void info(String message) {
    show(message: message);
  }
}

class _AppSnackbarContent extends StatelessWidget {
  final String message;

  const _AppSnackbarContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo on the left
          Image.asset(
            AppImages.appIcon,
            width: AppResponsive.iconSize(context, factor: 1.5),
            height: AppResponsive.iconSize(context, factor: 1.5),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image fails to load
              return Icon(
                Icons.info_outline,
                size: AppResponsive.iconSize(context, factor: 1.5),
                color: AppColors.white,
              );
            },
          ),
          AppSpacing.horizontal(context, 0.02),
          // Message
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(color: AppColors.white, fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
