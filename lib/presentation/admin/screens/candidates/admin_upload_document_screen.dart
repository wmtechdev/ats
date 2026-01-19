import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/documents/documents.dart';
import 'package:ats/core/widgets/common/forms/app_dropdown_field.dart' as dropdown;

class AdminUploadDocumentScreen extends StatefulWidget {
  const AdminUploadDocumentScreen({super.key});

  @override
  State<AdminUploadDocumentScreen> createState() =>
      _AdminUploadDocumentScreenState();
}

class _AdminUploadDocumentScreenState extends State<AdminUploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController expiryController;
  final _canSubmit = false.obs;
  final selectedDocTypeId = Rxn<String>();
  bool hasNoExpiry = false;
  final expiryError = Rxn<String>();

  bool get canSubmit {
    final candidatesController = Get.find<AdminCandidatesController>();
    return selectedDocTypeId.value != null &&
        selectedDocTypeId.value!.isNotEmpty &&
        candidatesController.selectedFile.value != null &&
        titleController.text.trim().isNotEmpty &&
        (hasNoExpiry || expiryController.text.trim().isNotEmpty) &&
        expiryError.value == null;
  }

  void _onFieldChanged() {
    _canSubmit.value = canSubmit;
    setState(() {});
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
    _onFieldChanged();
  }


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    expiryController = TextEditingController();
    titleController.addListener(_onFieldChanged);
    expiryController.addListener(validateExpiry);
    _canSubmit.value = canSubmit;
    
    // Observe file selection changes
    final candidatesController = Get.find<AdminCandidatesController>();
    ever(candidatesController.selectedFile, (_) => _onFieldChanged());
  }

  @override
  void dispose() {
    titleController.removeListener(_onFieldChanged);
    expiryController.removeListener(validateExpiry);
    titleController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidatesController = Get.find<AdminCandidatesController>();
    final documentsController = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.uploadDocument,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Document Type Dropdown
              Obx(() {
                final documentTypes = documentsController.documentTypes.toList();
                DocumentTypeEntity? selectedDocType;
                try {
                  selectedDocType = documentTypes.firstWhere(
                    (dt) => dt.docTypeId == selectedDocTypeId.value,
                  );
                } catch (e) {
                  selectedDocType = null;
                }
                return dropdown.AppDropDownField<DocumentTypeEntity>(
                  labelText: 'Document Type',
                  value: selectedDocType,
                  items: documentTypes
                      .map((dt) => DropdownMenuItem<DocumentTypeEntity>(
                            value: dt,
                            child: Text(dt.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedDocTypeId.value = value?.docTypeId;
                    _onFieldChanged();
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a document type';
                    }
                    return null;
                  },
                );
              }),
              AppSpacing.vertical(context, 0.02),
              // Title Field
              AppTextField(
                controller: titleController,
                labelText: AppTexts.documentTitle,
                prefixIcon: Iconsax.document_text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.documentTitleRequired;
                  }
                  if (value.trim().length < 3) {
                    return AppTexts.documentTitleMinLength;
                  }
                  return null;
                },
              ),
              AppSpacing.vertical(context, 0.02),
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
                onExpiryChanged: validateExpiry,
                expiryError: expiryError,
              ),
              AppSpacing.vertical(context, 0.02),
              // File Upload Section - Reuse existing widget
              AppDocumentUploadWidget(controller: candidatesController),
              AppSpacing.vertical(context, 0.03),
              // Upload Button
              Obx(
                () {
                  final isLoading = candidatesController.isLoading.value;
                  return AppButton(
                    text: AppTexts.upload,
                    icon: Iconsax.document_upload,
                    onPressed: _canSubmit.value && !isLoading
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              validateExpiry();
                              if (expiryError.value != null) {
                                AppSnackbar.error(expiryError.value!);
                                return;
                              }
                              final selectedFile = candidatesController.selectedFile.value;
                              if (selectedFile == null) {
                                AppSnackbar.error('Please select a document file');
                                return;
                              }
                              if (selectedDocTypeId.value == null) {
                                AppSnackbar.error('Please select a document type');
                                return;
                              }

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

                              candidatesController.uploadDocumentForCandidate(
                                docTypeId: selectedDocTypeId.value!,
                                title: titleController.text.trim(),
                                documentName: selectedFile.name,
                                platformFile: selectedFile,
                                expiryDate: expiryDate,
                                hasNoExpiry: hasNoExpiry,
                              );
                            }
                          }
                        : null,
                    isLoading: isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
