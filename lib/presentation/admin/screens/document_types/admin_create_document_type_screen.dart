import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCreateDocumentTypeScreen extends StatefulWidget {
  const AdminCreateDocumentTypeScreen({super.key});

  @override
  State<AdminCreateDocumentTypeScreen> createState() => _AdminCreateDocumentTypeScreenState();
}

class _AdminCreateDocumentTypeScreenState extends State<AdminCreateDocumentTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.createDocumentType,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: titleController,
                labelText: 'Document Title',
                prefixIcon: Iconsax.document_text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Document title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Document title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              AppSpacing.vertical(context, 0.02),
              AppTextField(
                controller: descriptionController,
                labelText: AppTexts.description,
                prefixIcon: Iconsax.document_text_1,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              AppSpacing.vertical(context, 0.03),
              Obx(() => AppButton(
                    text: AppTexts.create,
                    icon: Iconsax.add,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.createDocumentType(
                          name: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          isRequired: false, // Default to false as per user request
                        );
                      }
                    },
                    isLoading: controller.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

