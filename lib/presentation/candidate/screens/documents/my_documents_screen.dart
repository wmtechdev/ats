import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/widgets/app_widgets.dart';

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
                      final isUploadingThisItem = controller.uploadingDocTypeId.value == docType.docTypeId;
                      final currentProgress = controller.uploadProgress.value;
                      final currentHasDoc = controller.hasDocument(docType.docTypeId);
                      final currentDocument = controller.getDocumentByType(docType.docTypeId);
                      final documentStatus = currentDocument?.status ?? '';
                      final isPending = documentStatus == AppConstants.documentStatusPending;
                      final isDenied = documentStatus == AppConstants.documentStatusDenied;

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
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        LinearProgressIndicator(
                                          value: currentProgress,
                                          backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primary,
                                          ),
                                          minHeight: 6,
                                        ),
                                        AppSpacing.vertical(context, 0.005),
                                        Text(
                                          '${(currentProgress * 100).toStringAsFixed(0)}%',
                                          style: AppTextStyles.bodyText(context).copyWith(
                                            fontSize: AppTextStyles.bodyText(context).fontSize! * 0.75,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                              : currentHasDoc
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppStatusChip(status: documentStatus),
                                        // Show delete button when pending
                                        if (isPending) ...[
                                          AppSpacing.horizontal(context, 0.01),
                                          AppActionButton(
                                            text: AppTexts.delete,
                                            onPressed: () => _showDeleteConfirmation(
                                              context,
                                              controller,
                                              currentDocument!.candidateDocId,
                                              currentDocument.storageUrl,
                                              docType.name,
                                            ),
                                            backgroundColor: AppColors.error,
                                            foregroundColor: AppColors.white,
                                          ),
                                        ],
                                        // Show reupload button when denied
                                        if (isDenied) ...[
                                          AppSpacing.horizontal(context, 0.01),
                                          AppActionButton(
                                            text: AppTexts.reupload,
                                            onPressed: () => controller.uploadDocument(
                                              docType.docTypeId,
                                              docType.name,
                                            ),
                                            backgroundColor: AppColors.warning,
                                            foregroundColor: AppColors.black,
                                          ),
                                        ],
                                        // Approved: Only show status (no buttons)
                                      ],
                                    )
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
                      final currentUserDocs = controller.filteredUserDocuments.toList();
                      if (userDocIndex >= currentUserDocs.length) {
                        // Document was deleted, return empty container
                        return const SizedBox.shrink();
                      }
                      
                      final userDoc = currentUserDocs[userDocIndex];
                      final isPending = userDoc.status == AppConstants.documentStatusPending;
                      final isDenied = userDoc.status == AppConstants.documentStatusDenied;

                      return AppListCard(
                        title: userDoc.title ?? userDoc.documentName,
                        subtitle: userDoc.description ?? '',
                        icon: Iconsax.document_text,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppStatusChip(status: userDoc.status),
                            // Show delete button when pending
                            if (isPending) ...[
                              AppSpacing.horizontal(context, 0.01),
                              AppActionButton(
                                text: AppTexts.delete,
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  controller,
                                  userDoc.candidateDocId,
                                  userDoc.storageUrl,
                                  userDoc.title ?? userDoc.documentName,
                                ),
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.white,
                              ),
                            ],
                            // Show reupload button when denied
                            if (isDenied) ...[
                              AppSpacing.horizontal(context, 0.01),
                              AppActionButton(
                                text: AppTexts.reupload,
                                onPressed: () {
                                  // Navigate to create document screen with pre-filled data
                                  Get.toNamed(AppConstants.routeCandidateCreateDocument);
                                },
                                backgroundColor: AppColors.warning,
                                foregroundColor: AppColors.black,
                              ),
                            ],
                            // Approved: Only show status (no buttons)
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
