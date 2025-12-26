import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/document_type_entity.dart';

class AppRequiredDocumentsList extends StatelessWidget {
  final List<String> requiredDocumentIds;
  final Map<String, DocumentTypeEntity> documentTypesMap;
  final Map<String, bool> hasDocumentMap;

  const AppRequiredDocumentsList({
    super.key,
    required this.requiredDocumentIds,
    required this.documentTypesMap,
    required this.hasDocumentMap,
  });

  @override
  Widget build(BuildContext context) {
    if (requiredDocumentIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requiredDocumentIds.map((docId) {
        final docType = documentTypesMap[docId];
        final hasDoc = hasDocumentMap[docId] ?? false;

        if (docType == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(
            bottom: AppResponsive.screenHeight(context) * 0.01,
          ),
          child: Row(
            children: [
              Icon(
                hasDoc ? Iconsax.tick_circle : Iconsax.close_circle,
                size: AppResponsive.iconSize(context),
                color: hasDoc ? AppColors.success : AppColors.error,
              ),
              AppSpacing.horizontal(context, 0.01),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docType.name,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasDoc ? AppColors.success : AppColors.error,
                      ),
                    ),
                    if (docType.description.isNotEmpty)
                      Text(
                        docType.description,
                        style: AppTextStyles.bodyText(context),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
