import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/documents/app_document_upload_widget.dart';

class MyDocumentCreateScreen extends StatefulWidget {
  const MyDocumentCreateScreen({super.key});

  @override
  State<MyDocumentCreateScreen> createState() => _MyDocumentCreateScreenState();
}

class _MyDocumentCreateScreenState extends State<MyDocumentCreateScreen> {
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
    // Clear selected file when screen is disposed
    final controller = Get.find<DocumentsController>();
    controller.clearSelectedFile();
    super.dispose();
  }

  bool _validateForm() {
    final isValid = _formKey.currentState!.validate();
    final controller = Get.find<DocumentsController>();
    if (!isValid) return false;
    
    if (controller.selectedFile.value == null) {
      AppSnackbar.error(AppTexts.documentFileRequired);
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

    return AppCandidateLayout(
      title: AppTexts.addNewDocument,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDocumentFormFields(
                titleController: titleController,
                descriptionController: descriptionController,
              ),
              AppSpacing.vertical(context, 0.03),
              AppDocumentUploadWidget(controller: controller),
              AppSpacing.vertical(context, 0.03),
              Obx(() {
                final hasFile = controller.selectedFile.value != null;
                final canCreate = hasFile && 
                    titleController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty;
                
                return AppButton(
                  text: AppTexts.create,
                  icon: Iconsax.add,
                  onPressed: canCreate && !controller.isLoading.value
                      ? () {
                          if (_validateForm()) {
                            controller.createUserDocument(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                            );
                          }
                        }
                      : null,
                  isLoading: controller.isLoading.value,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

