import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobEditScreen extends StatefulWidget {
  const AdminJobEditScreen({super.key});

  @override
  State<AdminJobEditScreen> createState() => _AdminJobEditScreenState();
}

class _AdminJobEditScreenState extends State<AdminJobEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController requirementsController;
  String? selectedStatus;
  final Set<String> selectedDocumentIds = {};

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    requirementsController = TextEditingController();
    selectedStatus = null;
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
      title: AppTexts.editJob,
      child: Obx(() {
        final job = jobsController.selectedJob.value;
        if (job == null) {
          return AppEmptyState(
            message: AppTexts.jobNotFound,
            icon: Iconsax.document,
          );
        }

        // Initialize fields only once
        if (titleController.text.isEmpty) {
          titleController.text = job.title;
          descriptionController.text = job.description;
          requirementsController.text = job.requirements;
          selectedStatus = job.status;
          selectedDocumentIds.clear();
          selectedDocumentIds.addAll(job.requiredDocumentIds);
        }

        return SingleChildScrollView(
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
                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: AppTexts.status,
                    prefixIcon: Icon(
                      Iconsax.info_circle,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radius(context, factor: 5),
                      ),
                      borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radius(context, factor: 5),
                      ),
                      borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radius(context, factor: 5),
                      ),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: AppSpacing.symmetric(context, h: 0.04, v: 0.02),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AppConstants.jobStatusOpen,
                      child: Text('Open'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.jobStatusClosed,
                      child: Text('Closed'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
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
                        'No documents available.',
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
                      text: AppTexts.updateJob,
                      icon: Iconsax.edit,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          jobsController.updateJob(
                            jobId: job.jobId,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            requirements: requirementsController.text.trim(),
                            requiredDocumentIds: selectedDocumentIds.toList(),
                            status: selectedStatus,
                          );
                        }
                      },
                      isLoading: jobsController.isLoading.value,
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }
}
