import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';

class AppMissingDocumentsList extends StatelessWidget {
  final Map<String, Map<String, dynamic>> missingDocuments;
  final Function(String docTypeId) onRequest;

  const AppMissingDocumentsList({
    super.key,
    required this.missingDocuments,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    if (missingDocuments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.padding(context).copyWith(bottom: 0),
          itemCount: missingDocuments.length,
          itemBuilder: (context, index) {
            final entry = missingDocuments.values.elementAt(index);
            final docType = entry['docType'] as DocumentTypeEntity?;
            final docTypeId = entry['docTypeId'] as String;
            final jobTitles = entry['jobTitles'] as List<String>;

            // If document type is null, create a placeholder
            final docName = docType?.name ?? 'Unknown Document';
            final docDescription =
                docType?.description ?? 'Document type not found';

            return AppListCard(
              key: ValueKey('missing_doc_$docTypeId'),
              title: docName,
              subtitle: docDescription,
              icon: Iconsax.document_text,
              trailing: null,
              contentBelowSubtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppResponsive.screenWidth(context) * 0.01,
                    runSpacing: AppResponsive.screenHeight(context) * 0.005,
                    children: [
                      // Missing status chip
                      AppStatusChip(status: 'missing', customText: 'Missing'),
                      // Show job titles
                      if (jobTitles.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                AppResponsive.screenWidth(context) * 0.015,
                            vertical:
                                AppResponsive.screenHeight(context) * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radius(context, factor: 5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.briefcase,
                                size: AppResponsive.iconSize(context) * 0.8,
                                color: AppColors.primary,
                              ),
                              SizedBox(
                                width:
                                    AppResponsive.screenWidth(context) * 0.01,
                              ),
                              Text(
                                'Required for: ${jobTitles.join(', ')}',
                                style: AppTextStyles.bodyText(context).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      AppTextStyles.bodyText(
                                        context,
                                      ).fontSize! *
                                      0.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.vertical(context, 0.01),
                  // Single request button for all jobs
                  Obx(() {
                    final controller = Get.find<AdminCandidatesController>();
                    final isRequesting =
                        controller.isRequestingDocument[docTypeId] ?? false;

                    return AppActionButton(
                      text: isRequesting ? 'Requesting...' : 'Request Document',
                      onPressed: isRequesting
                          ? null
                          : () => onRequest(docTypeId),
                      backgroundColor: isRequesting
                          ? AppColors.grey
                          : AppColors.primary,
                      foregroundColor: AppColors.white,
                    );
                  }),
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
