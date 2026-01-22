import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';

// Direct import for web URL opening
import 'dart:html' as html if (dart.library.html) 'dart:html';

class AppWMSolsFooter extends StatelessWidget {
  const AppWMSolsFooter({super.key});

  void _openWMSolsWebsite() {
    if (kIsWeb) {
      try {
        html.window.open(AppConstants.wmsolsWebsiteUrl, '_blank');
      } catch (e) {
        // Fallback if window.open fails
        debugPrint('Failed to open URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(context, h: 0.03, v: 0.01),
      decoration: BoxDecoration(color: AppColors.primary),
      child: Center(
        child: GestureDetector(
          onTap: _openWMSolsWebsite,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              AppTexts.managedByWMSols,
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.isMobile(context)
                    ? AppResponsive.screenWidth(context) * 0.03
                    : 12.0,
                color: AppColors.white,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
