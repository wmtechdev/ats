import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/document_type_entity.dart';

class AppDocumentListItem extends StatelessWidget {
  final DocumentTypeEntity document;

  const AppDocumentListItem({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Iconsax.document_text,
          size: AppResponsive.iconSize(context),
          color: AppColors.primary,
        ),
        AppSpacing.horizontal(context, 0.01),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                document.name,
                style: AppTextStyles.bodyText(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
              if (document.description.isNotEmpty)
                Text(
                  document.description,
                  style: AppTextStyles.bodyText(context),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
