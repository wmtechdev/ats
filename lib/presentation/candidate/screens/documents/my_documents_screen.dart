import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_formatters.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    DocumentsController controller,
    String candidateDocId,
    String storageUrl,
    String documentName,
  ) {
    Get.dialog(
      AppAlertDialog(
        title: AppTexts.deleteDocument,
        subtitle: '${AppTexts.areYouSureDeleteDocument}: $documentName',
        primaryButtonText: AppTexts.delete,
        secondaryButtonText: AppTexts.cancel,
        onPrimaryPressed: () async {
          // Delete document - dialog will close automatically via AppAlertDialog
          await controller.deleteDocument(candidateDocId, storageUrl);
        },
        onSecondaryPressed: () {
          // Dialog will close automatically via AppAlertDialog
        },
        primaryButtonColor: AppColors.error,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

    return AppCandidateLayout(
      title: AppTexts.myDocuments,
      child: Column(
        children: [
          // Search and Add Section
          AppSearchCreateBar(
            searchHint: AppTexts.searchDocuments,
            createButtonText: AppTexts.addNewDocument,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeCandidateCreateDocument);
            },
          ),
          // Documents List
          Expanded(
            child: Obx(() {
              final adminDocs = controller.filteredDocumentTypes.toList();
              final userDocs = controller.filteredUserDocuments.toList();
              final hasAnyDocs = adminDocs.isNotEmpty || userDocs.isNotEmpty;

              if (!hasAnyDocs) {
                return AppEmptyState(
                  message:
                      controller.documentTypes.isEmpty &&
                          controller.candidateDocuments
                              .where((doc) => doc.isUserAdded)
                              .isEmpty
                      ? AppTexts.noDocumentTypesAvailable
                      : AppTexts.noDocumentsFound,
                  icon: Iconsax.document_text,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: adminDocs.length + userDocs.length,
                itemBuilder: (context, index) {
                  // Admin-provided documents first
                  if (index < adminDocs.length) {
                    final docType = adminDocs[index];

                    return Obx(() {
                      // Re-read reactive values inside Obx for this specific item
                      final isUploadingThisItem =
                          controller.uploadingDocTypeId.value ==
                          docType.docTypeId;
                      final currentProgress = controller.uploadProgress.value;
                      final currentHasDoc = controller.hasDocument(
                        docType.docTypeId,
                      );
                      final currentDocument = controller.getDocumentByType(
                        docType.docTypeId,
                      );
                      final documentStatus = currentDocument?.status ?? '';
                      final isPending =
                          documentStatus == AppConstants.documentStatusPending;
                      final isDenied =
                          documentStatus == AppConstants.documentStatusDenied;
                      final hasStorageUrl =
                          currentDocument?.storageUrl.isNotEmpty ?? false;

                      return Column(
                        children: [
                          AppListCard(
                            title: docType.name,
                            subtitle: docType.description,
                            icon: Iconsax.document_text,
                            trailing: isUploadingThisItem
                                ? SizedBox(
                                    width: 120,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        LinearProgressIndicator(
                                          value: currentProgress,
                                          backgroundColor: AppColors.grey
                                              .withValues(alpha: 0.2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                          minHeight: 6,
                                        ),
                                        AppSpacing.vertical(context, 0.005),
                                        Text(
                                          '${(currentProgress * 100).toStringAsFixed(0)}%',
                                          style: AppTextStyles.bodyText(context)
                                              .copyWith(
                                                fontSize:
                                                    AppTextStyles.bodyText(
                                                      context,
                                                    ).fontSize! *
                                                    0.75,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : currentHasDoc
                                ? null
                                : AppButton(
                                    backgroundColor: AppColors.primary,
                                    text: AppTexts.upload,
                                    icon: Iconsax.document_upload,
                                    onPressed: () => controller.uploadDocument(
                                      docType.docTypeId,
                                      docType.name,
                                    ),
                                    isFullWidth: false,
                                  ),
                            contentBelowSubtitle: currentHasDoc
                                ? Wrap(
                                    spacing: AppResponsive.screenWidth(context) * 0.01,
                                    runSpacing: AppResponsive.screenHeight(context) * 0.005,
                                    children: [
                                      AppStatusChip(status: documentStatus),
                                      // Show view button when document has been uploaded
                                      if (hasStorageUrl)
                                        AppActionButton(
                                          text: AppTexts.view,
                                          onPressed: () {
                                            AppDocumentViewer.show(
                                              documentUrl:
                                                  currentDocument!.storageUrl,
                                              documentName: docType.name,
                                            );
                                          },
                                          backgroundColor:
                                              AppColors.information,
                                          foregroundColor: AppColors.white,
                                        ),
                                      // Show delete button when pending
                                      if (isPending)
                                        AppActionButton(
                                          text: AppTexts.delete,
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                controller,
                                                currentDocument!.candidateDocId,
                                                currentDocument.storageUrl,
                                                docType.name,
                                              ),
                                          backgroundColor: AppColors.error,
                                          foregroundColor: AppColors.white,
                                        ),
                                      // Show reupload button when denied
                                      if (isDenied)
                                        AppActionButton(
                                          text: AppTexts.reupload,
                                          onPressed: () =>
                                              controller.uploadDocument(
                                                docType.docTypeId,
                                                docType.name,
                                              ),
                                          backgroundColor: AppColors.warning,
                                          foregroundColor: AppColors.black,
                                        ),
                                    ],
                                  )
                                : null,
                            onTap: null,
                          ),
                        ],
                      );
                    });
                  } else {
                    // User-added documents
                    final userDocIndex = index - adminDocs.length;

                    return Obx(() {
                      // Re-read reactive values inside Obx for this specific item
                      // Get the current document from the reactive list
                      final currentUserDocs = controller.filteredUserDocuments
                          .toList();
                      if (userDocIndex >= currentUserDocs.length) {
                        // Document was deleted, return empty container
                        return const SizedBox.shrink();
                      }

                      final userDoc = currentUserDocs[userDocIndex];
                      final isPending =
                          userDoc.status == AppConstants.documentStatusPending;
                      final isDenied =
                          userDoc.status == AppConstants.documentStatusDenied;
                      final hasStorageUrl = userDoc.storageUrl.isNotEmpty;
                      final expiryStatus = AppCandidateTableFormatters.formatExpiryStatus(userDoc);

                      return AppListCard(
                        title:
                            userDoc.title ??
                            AppFileValidator.extractOriginalFileName(
                              userDoc.documentName,
                            ),
                        subtitle: userDoc.description ?? '',
                        icon: Iconsax.document_text,
                        trailing: null,
                        contentBelowSubtitle: Wrap(
                          spacing: AppResponsive.screenWidth(context) * 0.01,
                          runSpacing: AppResponsive.screenHeight(context) * 0.005,
                          children: [
                            // Expiry Status Chip
                            if (expiryStatus != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppResponsive.screenWidth(context) * 0.01,
                                  vertical: AppResponsive.screenHeight(context) * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.expiry,
                                  borderRadius: BorderRadius.circular(
                                    AppResponsive.radius(context, factor: 5),
                                  ),
                                ),
                                child: Text(
                                  expiryStatus.toUpperCase(),
                                  style: AppTextStyles.bodyText(context).copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            AppStatusChip(status: userDoc.status),
                            // Show view button when document has been uploaded
                            if (hasStorageUrl)
                              AppActionButton(
                                text: AppTexts.view,
                                onPressed: () {
                                  AppDocumentViewer.show(
                                    documentUrl: userDoc.storageUrl,
                                    documentName:
                                        userDoc.title ??
                                        AppFileValidator.extractOriginalFileName(
                                          userDoc.documentName,
                                        ),
                                  );
                                },
                                backgroundColor: AppColors.information,
                                foregroundColor: AppColors.white,
                              ),
                            // Show delete button when pending
                            if (isPending)
                              AppActionButton(
                                text: AppTexts.delete,
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  controller,
                                  userDoc.candidateDocId,
                                  userDoc.storageUrl,
                                  userDoc.title ??
                                      AppFileValidator.extractOriginalFileName(
                                        userDoc.documentName,
                                      ),
                                ),
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.white,
                              ),
                            // Show reupload button when denied
                            if (isDenied)
                              AppActionButton(
                                text: AppTexts.reupload,
                                onPressed: () {
                                  // Navigate to create document screen with pre-filled data
                                  Get.toNamed(
                                    AppConstants.routeCandidateCreateDocument,
                                  );
                                },
                                backgroundColor: AppColors.warning,
                                foregroundColor: AppColors.black,
                              ),
                          ],
                        ),
                        onTap: null,
                      );
                    });
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
