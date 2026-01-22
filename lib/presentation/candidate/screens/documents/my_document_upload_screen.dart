import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class MyDocumentUploadScreen extends StatefulWidget {
  final String docTypeId;
  final String docTypeName;

  const MyDocumentUploadScreen({
    super.key,
    required this.docTypeId,
    required this.docTypeName,
  });

  @override
  State<MyDocumentUploadScreen> createState() =>
      _MyDocumentUploadScreenState();
}

class _MyDocumentUploadScreenState extends State<MyDocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController expiryController;
  bool hasNoExpiry = false;

  // Validation errors
  final expiryError = Rxn<String>();

  @override
  void initState() {
    super.initState();
    expiryController = TextEditingController();
  }

  @override
  void dispose() {
    expiryController.dispose();
    // Clear selected file when screen is disposed
    final controller = Get.find<DocumentsController>();
    controller.clearSelectedFile();
    super.dispose();
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
    // Validate expiry
    validateExpiry();

    final controller = Get.find<DocumentsController>();

    if (expiryError.value != null) {
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
      title: 'Upload ${widget.docTypeName}',
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Expiry Date Section
              AppDocumentExpirySection(
                expiryController: expiryController,
                hasNoExpiry: hasNoExpiry,
                onNoExpiryChanged: (value) {
                  setState(() {
                    hasNoExpiry = value;
                    if (value) {
                      expiryController.clear();
                    }
                    validateExpiry();
                  });
                },
                onExpiryChanged: () {
                  validateExpiry();
                },
                expiryError: expiryError,
              ),
              AppSpacing.vertical(context, 0.03),
              // Document Upload Widget
              AppDocumentUploadWidget(controller: controller),
              AppSpacing.vertical(context, 0.03),
              // Upload Button
              Obx(() {
                final hasFile = controller.selectedFile.value != null;
                final hasExpiry =
                    hasNoExpiry || expiryController.text.trim().isNotEmpty;
                final hasNoErrors = expiryError.value == null;
                final canUpload =
                    hasFile && hasExpiry && hasNoErrors;

                return AppButton(
                  text: AppTexts.upload,
                  icon: Iconsax.document_upload,
                  onPressed: canUpload && !controller.isLoading.value
                      ? () {
                          if (_validateForm()) {
                            // Parse expiry date if provided
                            DateTime? expiryDate;
                            if (!hasNoExpiry &&
                                expiryController.text.isNotEmpty) {
                              try {
                                final format = DateFormat('MM/yyyy');
                                expiryDate = format.parse(
                                  expiryController.text,
                                );
                              } catch (e) {
                                AppSnackbar.error(
                                  'Invalid expiry date format. Please use MM/YYYY',
                                );
                                return;
                              }
                            }

                            controller.uploadDocumentWithSelectedFile(
                              docTypeId: widget.docTypeId,
                              docTypeName: widget.docTypeName,
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
