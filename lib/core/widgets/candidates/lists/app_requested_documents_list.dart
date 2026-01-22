import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppRequestedDocumentsList extends StatelessWidget {
  final List<DocumentTypeEntity> requestedDocuments;
  final List<CandidateDocumentEntity> candidateDocuments;
  final Function(String docTypeId) onRevoke;
  final Function(String storageUrl)? onView;
  final Function(String candidateDocId, String status)? onStatusUpdate;
  final Function(String candidateDocId, String status, String? denialReason)?
  onDeny;

  const AppRequestedDocumentsList({
    super.key,
    required this.requestedDocuments,
    required this.candidateDocuments,
    required this.onRevoke,
    this.onView,
    this.onStatusUpdate,
    this.onDeny,
  });

  /// Check if a requested document has been uploaded
  bool isDocumentUploaded(String docTypeId) {
    return candidateDocuments.any((doc) => doc.docTypeId == docTypeId);
  }

  /// Get the uploaded document for a requested document type
  CandidateDocumentEntity? getUploadedDocument(String docTypeId) {
    try {
      return candidateDocuments.firstWhere((doc) => doc.docTypeId == docTypeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requestedDocuments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.padding(context).copyWith(bottom: 0, top: 0),
          itemCount: requestedDocuments.length,
          itemBuilder: (context, index) {
            final docType = requestedDocuments[index];
            final isUploaded = isDocumentUploaded(docType.docTypeId);
            final uploadedDoc = getUploadedDocument(docType.docTypeId);
            final documentStatus = uploadedDoc?.status ?? '';
            final hasStorageUrl = uploadedDoc?.storageUrl.isNotEmpty ?? false;
            final isPending =
                documentStatus == AppConstants.documentStatusPending;
            final isApproved =
                documentStatus == AppConstants.documentStatusApproved;
            final isRejected =
                documentStatus == AppConstants.documentStatusDenied;

            return AppListCard(
              key: ValueKey('requested_doc_${docType.docTypeId}'),
              title: docType.name,
              subtitle: docType.description,
              icon: Iconsax.document_text,
              trailing: null,
              contentBelowSubtitle: Wrap(
                spacing: AppResponsive.screenWidth(context) * 0.01,
                runSpacing: AppResponsive.screenHeight(context) * 0.005,
                children: [
                  // Requested badge
                  AppStatusChip(
                    status: AppConstants.documentStatusRequested,
                    showIcon: false,
                  ),
                  // Completion status
                  if (isUploaded) ...[
                    AppStatusChip(
                      status: AppConstants.documentStatusApproved,
                      customText: 'Uploaded',
                    ),
                    // Show document status if uploaded
                    if (documentStatus.isNotEmpty)
                      AppStatusChip(status: documentStatus),
                    // Show view/approve/deny buttons when document is pending
                    if (isPending &&
                        onView != null &&
                        onStatusUpdate != null &&
                        onDeny != null) ...[
                      AppActionButton(
                        text: AppTexts.view,
                        onPressed: () => onView!(uploadedDoc!.storageUrl),
                        backgroundColor: AppColors.information,
                        foregroundColor: AppColors.white,
                      ),
                      AppActionButton(
                        text: AppTexts.approve,
                        onPressed: () => onStatusUpdate!(
                          uploadedDoc!.candidateDocId,
                          AppConstants.documentStatusApproved,
                        ),
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                      ),
                      AppActionButton(
                        text: AppTexts.deny,
                        onPressed: () {
                          AppDocumentDenialDialog.show(
                            documentName: docType.name,
                            onConfirm: (reason) {
                              onDeny!(
                                uploadedDoc!.candidateDocId,
                                AppConstants.documentStatusDenied,
                                reason,
                              );
                            },
                            onCancel: () {},
                          );
                        },
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                    ],
                    // Show view button, status chip, and deny button when document is approved
                    if (isApproved && onView != null && onDeny != null) ...[
                      AppActionButton(
                        text: AppTexts.view,
                        onPressed: () => onView!(uploadedDoc!.storageUrl),
                        backgroundColor: AppColors.information,
                        foregroundColor: AppColors.white,
                      ),
                      AppActionButton(
                        text: AppTexts.deny,
                        onPressed: () {
                          AppDocumentDenialDialog.show(
                            documentName: docType.name,
                            onConfirm: (reason) {
                              onDeny!(
                                uploadedDoc!.candidateDocId,
                                AppConstants.documentStatusDenied,
                                reason,
                              );
                            },
                            onCancel: () {},
                          );
                        },
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                    ],
                    // Show view button, status chip, and approve button when document is denied
                    if (isRejected &&
                        onView != null &&
                        onStatusUpdate != null) ...[
                      AppActionButton(
                        text: AppTexts.view,
                        onPressed: () => onView!(uploadedDoc!.storageUrl),
                        backgroundColor: AppColors.information,
                        foregroundColor: AppColors.white,
                      ),
                      AppActionButton(
                        text: AppTexts.approve,
                        onPressed: () => onStatusUpdate!(
                          uploadedDoc!.candidateDocId,
                          AppConstants.documentStatusApproved,
                        ),
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                      ),
                    ],
                    // Fallback: show view button if no status-specific buttons are available
                    if (!isPending &&
                        !isApproved &&
                        !isRejected &&
                        hasStorageUrl &&
                        onView != null)
                      AppActionButton(
                        text: AppTexts.view,
                        onPressed: () => onView!(uploadedDoc!.storageUrl),
                        backgroundColor: AppColors.information,
                        foregroundColor: AppColors.white,
                      ),
                  ] else ...[
                    AppStatusChip(
                      status: AppConstants.documentStatusPending,
                      customText: 'NOT UPLOADED',
                    ),
                    // Show revoke button only when document is not uploaded
                    AppActionButton(
                      text: AppTexts.revoke,
                      onPressed: () => onRevoke(docType.docTypeId),
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                    ),
                  ],
                ],
              ),
              onTap: null,
            );
          },
        ),
      ],
    );
  }
}
