import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class MyDocumentCreateScreen extends StatefulWidget {
  const MyDocumentCreateScreen({super.key});

  @override
  State<MyDocumentCreateScreen> createState() => _MyDocumentCreateScreenState();
}

class _MyDocumentCreateScreenState extends State<MyDocumentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController expiryController;
  bool hasNoExpiry = false;

  // Validation errors
  final titleError = Rxn<String>();
  final descriptionError = Rxn<String>();
  final expiryError = Rxn<String>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    expiryController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    expiryController.dispose();
    // Clear selected file when screen is disposed
    final controller = Get.find<DocumentsController>();
    controller.clearSelectedFile();
    super.dispose();
  }

  // Validation methods
  void validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      titleError.value = AppTexts.documentTitleRequired;
    } else if (value.trim().length < 3) {
      titleError.value = AppTexts.documentTitleMinLength;
    } else {
      titleError.value = null;
    }
  }

  void validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      descriptionError.value = AppTexts.descriptionRequired;
    } else if (value.trim().length < 10) {
      descriptionError.value = AppTexts.descriptionMinLength;
    } else {
      descriptionError.value = null;
    }
  }

  void validateExpiry() {
    if (!hasNoExpiry && expiryController.text.trim().isEmpty) {
      expiryError.value = 'Please select an expiry date or check "No Expiry"';
    } else if (!hasNoExpiry && expiryController.text.trim().isNotEmpty) {
      // Validate that expiry date is not in the past
      try {
        final format = DateFormat('MM/yyyy');
        final expiryDate = format.parse(expiryController.text.trim());
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        final selectedMonth = DateTime(expiryDate.year, expiryDate.month);
        
        if (selectedMonth.isBefore(currentMonth)) {
          expiryError.value = 'Expiry date cannot be in the past';
        } else {
          expiryError.value = null;
        }
      } catch (e) {
        // Invalid date format - will be caught by other validation
        expiryError.value = null;
      }
    } else {
      expiryError.value = null;
    }
  }

  bool _validateForm() {
    // Validate all fields
    validateTitle(titleController.text);
    validateDescription(descriptionController.text);
    validateExpiry();

    final controller = Get.find<DocumentsController>();
    
    if (titleError.value != null || descriptionError.value != null || expiryError.value != null) {
      return false;
    }

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
                expiryController: expiryController,
                hasNoExpiry: hasNoExpiry,
                onTitleChanged: (value) {
                  validateTitle(value);
                },
                onDescriptionChanged: (value) {
                  validateDescription(value);
                },
                onExpiryChanged: () {
                  validateExpiry();
                },
                titleError: titleError,
                descriptionError: descriptionError,
                expiryError: expiryError,
                onNoExpiryChanged: (value) {
                  setState(() {
                    hasNoExpiry = value;
                    if (value) {
                      expiryController.clear();
                    }
                    validateExpiry();
                  });
                },
              ),
              AppSpacing.vertical(context, 0.03),
              AppDocumentUploadWidget(controller: controller),
              AppSpacing.vertical(context, 0.03),
              Obx(() {
                final hasFile = controller.selectedFile.value != null;
                final hasExpiry = hasNoExpiry || expiryController.text.trim().isNotEmpty;
                final hasNoErrors = titleError.value == null &&
                    descriptionError.value == null &&
                    expiryError.value == null;
                final canCreate =
                    hasFile &&
                    titleController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty &&
                    hasExpiry &&
                    hasNoErrors;

                return AppButton(
                  text: AppTexts.create,
                  icon: Iconsax.add,
                  onPressed: canCreate && !controller.isLoading.value
                      ? () {
                          if (_validateForm()) {
                            // Parse expiry date if provided
                            DateTime? expiryDate;
                            if (!hasNoExpiry && expiryController.text.isNotEmpty) {
                              try {
                                final format = DateFormat('MM/yyyy');
                                expiryDate = format.parse(expiryController.text);
                              } catch (e) {
                                AppSnackbar.error('Invalid expiry date format. Please use MM/YYYY');
                                return;
                              }
                            }

                            controller.createUserDocument(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              expiryDate: expiryDate,
                              hasNoExpiry: hasNoExpiry,
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
