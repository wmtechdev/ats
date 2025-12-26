import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppCandidateDocumentsList extends StatelessWidget {
  final List<CandidateDocumentEntity> documents;
  final Function(String candidateDocId, String status) onStatusUpdate;
  final Function(String storageUrl)? onView;

  const AppCandidateDocumentsList({
    super.key,
    required this.documents,
    required this.onStatusUpdate,
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

        return AppListCard(
          key: ValueKey('document_${doc.candidateDocId}'),
          title: doc.title ?? doc.documentName,
          subtitle: '${AppTexts.status}: ${doc.status}',
          icon: Iconsax.document_text,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              AppSpacing.horizontal(context, 0.01),
              AppActionButton(
                text: AppTexts.approved,
                onPressed: () => onStatusUpdate(
                  doc.candidateDocId,
                  AppConstants.documentStatusApproved,
                ),
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
              AppSpacing.horizontal(context, 0.01),
              AppActionButton(
                text: AppTexts.denied,
                onPressed: () => onStatusUpdate(
                  doc.candidateDocId,
                  AppConstants.documentStatusDenied,
                ),
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              if (isRejected) ...[
                AppSpacing.horizontal(context, 0.01),
                AppActionButton(
                  text: AppTexts.request,
                  onPressed: () {
                    // TODO: Implement request functionality
                  },
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.black,
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

