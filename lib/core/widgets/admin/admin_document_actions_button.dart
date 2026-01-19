import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:get/get.dart';

/// Reusable widget for admin document actions (Request Document and Upload Document)
/// Displays a popup menu button with both options
class AdminDocumentActionsButton extends StatelessWidget {
  const AdminDocumentActionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Iconsax.more,
          color: AppColors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'request',
          child: Row(
            children: [
              Icon(
                Iconsax.document_text,
                color: AppColors.primary,
              ),
              SizedBox(
                width: AppSpacing.horizontal(
                  context,
                  0.02,
                ).width,
              ),
              Text(AppTexts.requestDocument),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'upload',
          child: Row(
            children: [
              Icon(
                Iconsax.document_upload,
                color: AppColors.primary,
              ),
              SizedBox(
                width: AppSpacing.horizontal(
                  context,
                  0.02,
                ).width,
              ),
              Text(AppTexts.uploadDocument),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'request') {
          Get.toNamed(
            AppConstants.routeAdminRequestDocument,
          );
        } else if (value == 'upload') {
          Get.toNamed(
            AppConstants.routeAdminUploadDocument,
          );
        }
      },
    );
  }
}
