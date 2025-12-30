import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_images/app_images.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/common/app_text_field.dart';
import 'package:ats/core/widgets/common/app_action_button.dart';

class AppDocumentDenialDialog extends StatefulWidget {
  final String documentName;
  final Function(String? reason) onConfirm;
  final VoidCallback onCancel;

  const AppDocumentDenialDialog({
    super.key,
    required this.documentName,
    required this.onConfirm,
    required this.onCancel,
  });

  static void show({
    required String documentName,
    required Function(String? reason) onConfirm,
    required VoidCallback onCancel,
  }) {
    Get.dialog(
      AppDocumentDenialDialog(
        documentName: documentName,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<AppDocumentDenialDialog> createState() =>
      _AppDocumentDenialDialogState();
}

class _AppDocumentDenialDialogState extends State<AppDocumentDenialDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
      ),
      child: Container(
        padding: AppSpacing.all(context, factor: 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Image.asset(
              AppImages.appLogo,
              height: AppResponsive.screenHeight(context) * 0.08,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business_center,
                size: AppResponsive.screenHeight(context) * 0.06,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vertical(context, 0.02),
            // Title
            Text(
              AppTexts.denyDocument,
              style: AppTextStyles.heading(
                context,
              ).copyWith(fontWeight: FontWeight.w700, color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.015),
            // Subtitle with document name
            Text(
              '${AppTexts.documentName}: ${widget.documentName}\n\n${AppTexts.denyDocumentConfirmation}',
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(fontWeight: FontWeight.w500, color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.02),
            // Reason field (optional)
            Text(
              '${AppTexts.denialReason} (${AppTexts.optional})',
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(color: AppColors.white, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.01),
            AppTextField(
              controller: _reasonController,
              hintText: AppTexts.denialReasonHint,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            AppSpacing.vertical(context, 0.02),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppActionButton(
                  text: AppTexts.cancel,
                  onPressed: () {
                    Get.back();
                    widget.onCancel();
                  },
                  backgroundColor: AppColors.lightGrey,
                  foregroundColor: AppColors.black,
                ),
                AppSpacing.horizontal(context, 0.02),
                AppActionButton(
                  text: AppTexts.deny,
                  onPressed: () {
                    final reason = _reasonController.text.trim();
                    Get.back();
                    widget.onConfirm(reason.isEmpty ? null : reason);
                  },
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
