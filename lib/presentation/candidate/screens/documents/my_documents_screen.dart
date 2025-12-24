import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
      child: Obx(() => controller.documentTypes.isEmpty
          ? AppEmptyState(
              message: AppTexts.noDocumentTypesAvailable,
              icon: Iconsax.document_text,
            )
          : ListView.builder(
              padding: AppSpacing.padding(context),
              itemCount: controller.documentTypes.length,
              itemBuilder: (context, index) {
                final docType = controller.documentTypes[index];
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
              },
            )),
    );
  }
}
