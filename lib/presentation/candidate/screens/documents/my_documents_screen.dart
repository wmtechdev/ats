import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

    return AppCandidateLayout(
      title: AppTexts.myDocuments,
      child: Column(
        children: [
          // Search and Add Section
          AppSearchCreateBar(
            searchHint: AppTexts.searchDocuments,
            createButtonText: AppTexts.addNewDocument,
            createButtonIcon: Iconsax.add,
            onSearchChanged: (value) => controller.setSearchQuery(value),
            onCreatePressed: () {
              Get.toNamed(AppConstants.routeCandidateCreateDocument);
            },
          ),
          // Documents List
          Expanded(
            child: Obx(() {
              final adminDocs = controller.filteredDocumentTypes.toList();
              final userDocs = controller.filteredUserDocuments.toList();
              final hasAnyDocs = adminDocs.isNotEmpty || userDocs.isNotEmpty;

              if (!hasAnyDocs) {
                return AppEmptyState(
                  message: controller.documentTypes.isEmpty &&
                          controller.candidateDocuments
                              .where((doc) => doc.isUserAdded)
                              .isEmpty
                      ? AppTexts.noDocumentTypesAvailable
                      : AppTexts.noDocumentsFound,
                  icon: Iconsax.document_text,
                );
              }

              return ListView.builder(
                padding: AppSpacing.padding(context),
                itemCount: adminDocs.length + userDocs.length,
                itemBuilder: (context, index) {
                  // Admin-provided documents first
                  if (index < adminDocs.length) {
                    final docType = adminDocs[index];
                    final hasDoc = controller.hasDocument(docType.docTypeId);
                    final document = controller.getDocumentByType(docType.docTypeId);

                    return AppListCard(
                      title: docType.name,
                      subtitle: docType.description,
                      icon: Iconsax.document_text,
                      trailing: hasDoc
                          ? AppStatusChip(
                              status: document?.status ?? 'pending',
                            )
                          : AppButton(
                              text: AppTexts.upload,
                              icon: Iconsax.document_upload,
                              onPressed: () => controller.uploadDocument(
                                docType.docTypeId,
                                docType.name,
                              ),
                              isFullWidth: false,
                            ),
                      onTap: null,
                    );
                  } else {
                    // User-added documents
                    final userDoc = userDocs[index - adminDocs.length];
                    return AppListCard(
                      title: userDoc.title ?? userDoc.documentName,
                      subtitle: userDoc.description ?? '',
                      icon: Iconsax.document_text,
                      trailing: AppStatusChip(
                        status: userDoc.status,
                      ),
                      onTap: null,
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
