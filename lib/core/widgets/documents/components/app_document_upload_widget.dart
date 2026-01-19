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

/// Reusable document upload widget that works with any controller
/// that implements the required reactive properties and methods
class AppDocumentUploadWidget extends StatelessWidget {
  final dynamic controller;

  const AppDocumentUploadWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.documentFile,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.vertical(context, 0.01),
        Obx(() {
          final hasFile = controller.selectedFile.value != null;
          final fileName = controller.selectedFileName.value;
          final fileSize = controller.selectedFileSize.value;
          final isUploading = controller.isUploading.value;
          final uploadProgress = controller.uploadProgress.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasFile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.document_text,
                          size: AppResponsive.iconSize(context),
                          color: AppColors.primary,
                        ),
                        AppSpacing.horizontal(context, 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: AppTextStyles.bodyText(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (fileSize.isNotEmpty)
                                Text(
                                  fileSize,
                                  style: AppTextStyles.bodyText(context)
                                      .copyWith(
                                        fontSize:
                                            AppTextStyles.bodyText(
                                              context,
                                            ).fontSize! *
                                            0.85,
                                        color: AppColors.grey,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        if (!isUploading)
                          IconButton(
                            icon: Icon(
                              Iconsax.close_circle,
                              size: AppResponsive.iconSize(context),
                              color: AppColors.error,
                            ),
                            onPressed: () => controller.clearSelectedFile(),
                          ),
                      ],
                    ),
                    if (isUploading) ...[
                      AppSpacing.vertical(context, 0.01),
                      LinearProgressIndicator(
                        value: uploadProgress,
                        backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                      AppSpacing.vertical(context, 0.005),
                      Text(
                        'Uploading: ${(uploadProgress * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.bodyText(context).copyWith(
                          fontSize:
                              AppTextStyles.bodyText(context).fontSize! * 0.85,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                        style: AppTextStyles.bodyText(
                          context,
                        ).copyWith(color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              AppSpacing.vertical(context, 0.02),
              AppButton(
                text: isUploading
                    ? AppTexts.uploading
                    : hasFile
                    ? AppTexts.upload
                    : AppTexts.selectDocument,
                icon: isUploading
                    ? Iconsax.refresh
                    : hasFile
                    ? Iconsax.document_upload
                    : Iconsax.folder,
                onPressed: isUploading
                    ? null
                    : () {
                        // Support both DocumentsController and AdminCandidatesController
                        if (controller is DocumentsController) {
                          controller.pickFileForUserDocument();
                        } else {
                          // AdminCandidatesController
                          controller.pickFileForAdminUpload();
                        }
                      },
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
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
