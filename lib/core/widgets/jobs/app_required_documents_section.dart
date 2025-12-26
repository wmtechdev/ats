import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/jobs/app_content_section.dart';
import 'package:ats/core/widgets/jobs/app_document_list_item.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:flutter/material.dart';

class AppRequiredDocumentsSection extends StatelessWidget {
  const AppRequiredDocumentsSection({
    super.key,
    required this.requiredDocuments,
  });

  final List<DocumentTypeEntity> requiredDocuments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.requiredDocuments,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        AppSpacing.vertical(context, 0.01),
        if (requiredDocuments.isEmpty)
          AppContentSection(title: '', content: AppTexts.noRequiredDocuments)
        else
          ...requiredDocuments.map((doc) => AppDocumentListItem(document: doc)),
      ],
    );
  }
}
