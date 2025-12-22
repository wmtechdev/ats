import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';

class AppErrorMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final TextAlign? textAlign;
  final Color? messageColor;

  const AppErrorMessage({
    super.key,
    required this.message,
    this.icon,
    this.textAlign,
    this.messageColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = AppResponsive.screenWidth(context);
    final height = AppResponsive.screenHeight(context);

    double topPadding;
    double horizontalPadding;
    double iconSpacing;

    if (AppResponsive.isMobile(context)) {
      topPadding = height * 0.01;
      horizontalPadding = width * 0.02;
      iconSpacing = width * 0.01;
    } else if (AppResponsive.isTablet(context)) {
      topPadding = height * 0.01 * 0.8;
      horizontalPadding = width * 0.02 * 0.8;
      iconSpacing = width * 0.01 * 0.8;
    } else {
      topPadding = 8.0;
      horizontalPadding = 16.0;
      iconSpacing = 8.0;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppResponsive.iconSize(context, factor: 0.8),
              color: messageColor,
            ),
            SizedBox(width: iconSpacing),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyText(context).copyWith(
                color: messageColor,
                fontSize: AppResponsive.scaleSize(context, 12),
              ),
              textAlign: textAlign ?? TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
