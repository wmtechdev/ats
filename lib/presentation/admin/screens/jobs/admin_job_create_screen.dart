import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobCreateScreen extends StatefulWidget {
  const AdminJobCreateScreen({super.key});

  @override
  State<AdminJobCreateScreen> createState() => _AdminJobCreateScreenState();
}

class _AdminJobCreateScreenState extends State<AdminJobCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController requirementsController;
  final Set<String> selectedDocumentIds = {};

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    requirementsController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsController = Get.find<AdminJobsController>();
    final documentsController = Get.find<AdminDocumentsController>();

    return AppAdminLayout(
      title: AppTexts.createJob,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: titleController,
                labelText: AppTexts.jobTitle,
                prefixIcon: Iconsax.briefcase,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Job title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              AppSpacing.vertical(context, 0.02),
              AppTextField(
                controller: descriptionController,
                labelText: AppTexts.description,
                prefixIcon: Iconsax.document_text,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Job description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              AppSpacing.vertical(context, 0.02),
              AppTextField(
                controller: requirementsController,
                labelText: AppTexts.requirements,
                prefixIcon: Iconsax.tick_circle,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requirements are required';
                  }
                  return null;
                },
              ),
              AppSpacing.vertical(context, 0.02),
              Text(
                'Required Documents',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.vertical(context, 0.01),
              Obx(() {
                if (documentsController.filteredDocumentTypes.isEmpty) {
                  return Container(
                    padding: AppSpacing.all(context),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radius(context, factor: 5),
                      ),
                    ),
                    child: Text(
                      'No documents available. Create documents first.',
                      style: TextStyle(
                        color: AppColors.grey,
                      ),
                    ),
                  );
                }

                return Container(
                  constraints: BoxConstraints(
                    maxHeight: AppResponsive.screenHeight(context) * 0.3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(
                      AppResponsive.radius(context, factor: 5),
                    ),
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: documentsController.filteredDocumentTypes.length,
                    itemBuilder: (context, index) {
                      final docType = documentsController.filteredDocumentTypes[index];
                      final isSelected = selectedDocumentIds.contains(docType.docTypeId);

                      return CheckboxListTile(
                        title: Text(docType.name),
                        subtitle: Text(
                          docType.description,
                          style: TextStyle(fontSize: 12),
                        ),
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedDocumentIds.add(docType.docTypeId);
                            } else {
                              selectedDocumentIds.remove(docType.docTypeId);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              }),
              AppSpacing.vertical(context, 0.03),
              Obx(() => AppButton(
                    text: AppTexts.createJob,
                    icon: Iconsax.add,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        jobsController.createJob(
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          requirements: requirementsController.text.trim(),
                          requiredDocumentIds: selectedDocumentIds.toList(),
                        );
                      }
                    },
                    isLoading: jobsController.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
