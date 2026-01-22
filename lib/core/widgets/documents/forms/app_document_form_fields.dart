import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppDocumentFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController? expiryController;
  final bool hasNoExpiry;
  final void Function(bool)? onNoExpiryChanged;
  final void Function(String)? onTitleChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function()? onExpiryChanged;
  final Rxn<String>? titleError;
  final Rxn<String>? descriptionError;
  final Rxn<String>? expiryError;

  const AppDocumentFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.expiryController,
    this.hasNoExpiry = false,
    this.onNoExpiryChanged,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onExpiryChanged,
    this.titleError,
    this.descriptionError,
    this.expiryError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: titleController,
          labelText: AppTexts.documentTitle,
          prefixIcon: Iconsax.document_text,
          onChanged: onTitleChanged,
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
        if (titleError != null)
          Obx(
            () => titleError!.value != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppSpacing.vertical(context, 0.01).height!,
                    ),
                    child: AppErrorMessage(
                      message: titleError!.value!,
                      icon: Iconsax.info_circle,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: descriptionController,
          labelText: AppTexts.description,
          prefixIcon: Iconsax.document_text_1,
          maxLines: 5,
          onChanged: onDescriptionChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppTexts.descriptionRequired;
            }
            if (value.trim().length < 10) {
              return AppTexts.descriptionMinLength;
            }
            return null;
          },
        ),
        if (descriptionError != null)
          Obx(
            () => descriptionError!.value != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppSpacing.vertical(context, 0.01).height!,
                    ),
                    child: AppErrorMessage(
                      message: descriptionError!.value!,
                      icon: Iconsax.info_circle,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        // Expiry Date Section (only shown if expiryController is provided)
        // Use AppDocumentExpirySection for real-time checkbox updates
        if (expiryController != null && onNoExpiryChanged != null) ...[
          AppSpacing.vertical(context, 0.02),
          AppDocumentExpirySection(
            expiryController: expiryController!,
            hasNoExpiry: hasNoExpiry,
            onNoExpiryChanged: onNoExpiryChanged!,
            onExpiryChanged: onExpiryChanged,
            expiryError: expiryError,
          ),
        ],
      ],
    );
  }
}
