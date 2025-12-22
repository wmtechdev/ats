import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Iconsax.document_text,
            size: AppResponsive.iconSize(context, factor: 3),
            color: AppColors.grey,
          ),
          SizedBox(height: AppResponsive.screenHeight(context) * 0.02),
          Text(
            message,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

