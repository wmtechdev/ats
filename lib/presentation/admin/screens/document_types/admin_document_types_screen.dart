import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminDocumentTypesScreen extends StatelessWidget {
  const AdminDocumentTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDocumentsController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(
        title: AppTexts.documentTypes,
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.add,
              size: AppResponsive.iconSize(context),
              color: AppColors.primary,
            ),
            onPressed: () {
              _showCreateDialog(context, controller);
            },
          ),
        ],
      ),
      body: Obx(() => controller.documentTypes.isEmpty
          ? AppEmptyState(
              message: AppTexts.noDocumentTypesAvailable,
              icon: Iconsax.document_text,
            )
          : ListView.builder(
              padding: AppSpacing.padding(context),
              itemCount: controller.documentTypes.length,
              itemBuilder: (context, index) {
                final docType = controller.documentTypes[index];
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
            )),
    );
  }

  void _showCreateDialog(BuildContext context, AdminDocumentsController controller) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final isRequired = true.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        ),
        title: Text(
          AppTexts.createDocumentType,
          style: AppTextStyles.heading(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              labelText: AppTexts.name,
              prefixIcon: Iconsax.document_text,
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: descriptionController,
              labelText: AppTexts.description,
              prefixIcon: Iconsax.document_text_1,
            ),
            AppSpacing.vertical(context, 0.01),
            Obx(() => CheckboxListTile(
                  title: Text(
                    AppTexts.isRequired,
                    style: AppTextStyles.bodyText(context),
                  ),
                  value: isRequired.value,
                  activeColor: AppColors.primary,
                  onChanged: (value) => isRequired.value = value ?? true,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppTexts.cancel,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          AppButton(
            text: AppTexts.create,
            onPressed: () {
              controller.createDocumentType(
                name: nameController.text,
                description: descriptionController.text,
                isRequired: isRequired.value,
              );
              Get.back();
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
