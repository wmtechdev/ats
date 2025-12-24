import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppDocumentUploadWidget extends StatelessWidget {
  final DocumentsController controller;

  const AppDocumentUploadWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.documentFile,
          style: AppTextStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        Obx(() {
          final hasFile = controller.selectedFile.value != null;
          final fileName = controller.selectedFileName.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasFile)
                Row(
                  children: [
                    Icon(
                      Iconsax.document_text,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.primary,
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Expanded(
                      child: Text(
                        fileName,
                        style: AppTextStyles.bodyText(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        size: AppResponsive.iconSize(context),
                        color: AppColors.error,
                      ),
                      onPressed: () => controller.clearSelectedFile(),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      Iconsax.document_text,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.grey,
                    ),
                    AppSpacing.horizontal(context, 0.02),
                    Expanded(
                      child: Text(
                        AppTexts.noFileSelected,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              AppSpacing.vertical(context, 0.02),
              AppButton(
                text: hasFile ? AppTexts.upload : AppTexts.selectDocument,
                icon: hasFile ? Iconsax.document_upload : Iconsax.folder,
                onPressed: () => controller.pickFileForUserDocument(),
                isFullWidth: true,
              ),
            ],
          );
        }),
        if (controller.errorMessage.value.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: AppResponsive.screenHeight(context) * 0.01,
            ),
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}

