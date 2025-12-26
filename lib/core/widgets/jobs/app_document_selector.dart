import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/document_type_entity.dart';

class AppDocumentSelector extends StatelessWidget {
  final List<DocumentTypeEntity> documents;
  final Set<String> selectedDocumentIds;
  final void Function(String, bool) onSelectionChanged;
  final String emptyMessage;

  const AppDocumentSelector({
    super.key,
    required this.documents,
    required this.selectedDocumentIds,
    required this.onSelectionChanged,
    this.emptyMessage = AppTexts.noDocumentsAvailable,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final docType = documents[index];
        final isSelected = selectedDocumentIds.contains(docType.docTypeId);

        return CheckboxListTile(
          title: Text(
            docType.name,
            style: AppTextStyles.bodyText(context),
          ),
          subtitle: docType.description.isNotEmpty
              ? Text(
                  docType.description,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontSize: 12,
                  ),
                )
              : null,
          value: isSelected,
          activeColor: AppColors.primary,
          onChanged: (value) {
            onSelectionChanged(docType.docTypeId, value ?? false);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: AppSpacing.all(context),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 5),
        ),
      ),
      child: Text(
        emptyMessage,
        style: AppTextStyles.bodyText(context).copyWith(
          color: AppColors.grey,
        ),
      ),
    );
  }
}

