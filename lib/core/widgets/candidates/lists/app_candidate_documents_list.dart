import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppCandidateDocumentsList extends StatelessWidget {
  final List<CandidateDocumentEntity> documents;
  final Function(String candidateDocId, String status) onStatusUpdate;
  final Function(String candidateDocId, String status, String? denialReason)?
  onDeny;
  final Function(String storageUrl)? onView;

  const AppCandidateDocumentsList({
    super.key,
    required this.documents,
    required this.onStatusUpdate,
    this.onDeny,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return AppEmptyState(
        message: AppTexts.noDocumentsFound,
        icon: Iconsax.document_text,
      );
    }

    return ListView.builder(
      padding: AppSpacing.padding(context),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final isRejected = doc.status == AppConstants.documentStatusDenied;
        final isApproved = doc.status == AppConstants.documentStatusApproved;
        final isPending = doc.status == AppConstants.documentStatusPending;
        final expiryStatus = AppCandidateTableFormatters.formatExpiryStatus(
          doc,
        );

        return AppListCard(
          key: ValueKey('document_${doc.candidateDocId}'),
          title:
              doc.title ??
              AppFileValidator.extractOriginalFileName(doc.documentName),
          subtitle: '${AppTexts.status}: ${doc.status}',
          icon: Iconsax.document_text,
          trailing: null,
          contentBelowSubtitle: Wrap(
            spacing: AppResponsive.screenWidth(context) * 0.01,
            runSpacing: AppResponsive.screenHeight(context) * 0.005,
            children: [
              // Expiry Status Chip (always show if document has expiry info)
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
              // Show view/approve/deny buttons when document is pending
              if (isPending) ...[
                AppActionButton(
                  text: AppTexts.view,
                  onPressed: () {
                    if (doc.storageUrl.isNotEmpty && onView != null) {
                      onView!(doc.storageUrl);
                    }
                  },
                  backgroundColor: AppColors.information,
                  foregroundColor: AppColors.white,
                ),
                AppActionButton(
                  text: AppTexts.approve,
                  onPressed: () => onStatusUpdate(
                    doc.candidateDocId,
                    AppConstants.documentStatusApproved,
                  ),
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                ),
                AppActionButton(
                  text: AppTexts.deny,
                  onPressed: () {
                    final documentName =
                        doc.title ??
                        AppFileValidator.extractOriginalFileName(
                          doc.documentName,
                        );
                    AppDocumentDenialDialog.show(
                      documentName: documentName,
                      onConfirm: (reason) {
                        if (onDeny != null) {
                          onDeny!(
                            doc.candidateDocId,
                            AppConstants.documentStatusDenied,
                            reason,
                          );
                        } else {
                          onStatusUpdate(
                            doc.candidateDocId,
                            AppConstants.documentStatusDenied,
                          );
                        }
                      },
                      onCancel: () {
                        // User cancelled, do nothing
                      },
                    );
                  },
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
              ],
              // Show view button, status chip, and deny button when document is approved
              if (isApproved) ...[
                AppActionButton(
                  text: AppTexts.view,
                  onPressed: () {
                    if (doc.storageUrl.isNotEmpty && onView != null) {
                      onView!(doc.storageUrl);
                    }
                  },
                  backgroundColor: AppColors.information,
                  foregroundColor: AppColors.white,
                ),
                AppStatusChip(status: doc.status),
                AppActionButton(
                  text: AppTexts.deny,
                  onPressed: () {
                    final documentName =
                        doc.title ??
                        AppFileValidator.extractOriginalFileName(
                          doc.documentName,
                        );
                    AppDocumentDenialDialog.show(
                      documentName: documentName,
                      onConfirm: (reason) {
                        if (onDeny != null) {
                          onDeny!(
                            doc.candidateDocId,
                            AppConstants.documentStatusDenied,
                            reason,
                          );
                        } else {
                          onStatusUpdate(
                            doc.candidateDocId,
                            AppConstants.documentStatusDenied,
                          );
                        }
                      },
                      onCancel: () {
                        // User cancelled, do nothing
                      },
                    );
                  },
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
              ],
              // Show view button, status chip, and approve button when document is denied
              if (isRejected) ...[
                AppActionButton(
                  text: AppTexts.view,
                  onPressed: () {
                    if (doc.storageUrl.isNotEmpty && onView != null) {
                      onView!(doc.storageUrl);
                    }
                  },
                  backgroundColor: AppColors.information,
                  foregroundColor: AppColors.white,
                ),
                AppStatusChip(status: doc.status),
                AppActionButton(
                  text: AppTexts.approve,
                  onPressed: () => onStatusUpdate(
                    doc.candidateDocId,
                    AppConstants.documentStatusApproved,
                  ),
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                ),
              ],
            ],
          ),
          onTap: null,
        );
      },
    );
  }
}
