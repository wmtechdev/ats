import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
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
          AppSearchCreateBar(
            searchHint: AppTexts.searchDocuments,
            createButtonText: AppTexts.createDocumentType,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeAdminCreateDocumentType);
            },
          ),
          // Documents List
          Expanded(
            child: Obx(() {
              final filteredDocs = controller.filteredDocumentTypes.toList();
              final allDocs = controller.documentTypes.toList();

              if (filteredDocs.isEmpty) {
                return AppEmptyState(
                  message: allDocs.isEmpty
                      ? AppTexts.noDocumentTypesAvailable
                      : AppTexts.noDocumentsFound,
                  icon: Iconsax.document_text,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final docType = filteredDocs[index];
                  return AppListCard(
                    title: docType.name,
                    subtitle: docType.description,
                    icon: Iconsax.document_text,
                    trailing: AppActionButton.delete(
                      onPressed: () =>
                          controller.deleteDocumentType(docType.docTypeId),
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
