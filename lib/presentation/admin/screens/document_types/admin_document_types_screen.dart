import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminDocumentTypesScreen extends StatelessWidget {
  const AdminDocumentTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.documentTypes,
      child: Column(
        children: [
          // Search and Create Section
          Container(
            padding: AppSpacing.padding(context),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hintText: 'Search documents by title or description...',
                    prefixIcon: Iconsax.search_normal,
                    onChanged: (value) => controller.setSearchQuery(value),
                  ),
                ),
                AppSpacing.horizontal(context, 0.02),
                AppButton(
                  text: AppTexts.createDocumentType,
                  icon: Iconsax.add,
                  onPressed: () {
                    Get.toNamed(AppConstants.routeAdminCreateDocumentType);
                  },
                  isFullWidth: false,
                ),
              ],
            ),
          ),
          // Documents List
          Expanded(
            child: Obx(() {
              if (controller.filteredDocumentTypes.isEmpty) {
                return AppEmptyState(
                  message: controller.documentTypes.isEmpty
                      ? AppTexts.noDocumentTypesAvailable
                      : 'No documents found matching your search',
                  icon: Iconsax.document_text,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: controller.filteredDocumentTypes.length,
                itemBuilder: (context, index) {
                  final docType = controller.filteredDocumentTypes[index];
                  return AppListCard(
                    title: docType.name,
                    subtitle: docType.description,
                    icon: Iconsax.document_text,
                    trailing: IconButton(
                      icon: Icon(
                        Iconsax.trash,
                        size: AppResponsive.iconSize(context),
                        color: AppColors.error,
                      ),
                      onPressed: () => controller.deleteDocumentType(docType.docTypeId),
                    ),
                    onTap: null,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
