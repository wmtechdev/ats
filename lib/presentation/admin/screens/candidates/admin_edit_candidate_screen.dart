import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminEditCandidateScreen extends StatefulWidget {
  const AdminEditCandidateScreen({super.key});

  @override
  State<AdminEditCandidateScreen> createState() =>
      _AdminEditCandidateScreenState();
}

class _AdminEditCandidateScreenState extends State<AdminEditCandidateScreen> {
  final controller = Get.find<AdminCandidatesController>();
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  // Work history controllers
  final List<Map<String, TextEditingController>> workHistoryControllers = [];

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    // Load existing profile data when it becomes available
    ever(controller.selectedCandidateProfile, (profile) {
      if (profile != null && mounted) {
        // Only update if controllers are empty or different
        if (firstNameController.text.isEmpty ||
            firstNameController.text != profile.firstName) {
          firstNameController.text = profile.firstName;
        }
        if (lastNameController.text.isEmpty ||
            lastNameController.text != profile.lastName) {
          lastNameController.text = profile.lastName;
        }
        if (phoneController.text.isEmpty ||
            phoneController.text != profile.phone) {
          phoneController.text = profile.phone;
        }
        if (addressController.text.isEmpty ||
            addressController.text != profile.address) {
          addressController.text = profile.address;
        }

        // Load work history
        if (profile.workHistory != null && profile.workHistory!.isNotEmpty) {
          // Always rebuild if work history exists and controllers are empty or lengths differ
          if (workHistoryControllers.isEmpty ||
              workHistoryControllers.length != profile.workHistory!.length) {
            // Clear existing and rebuild
            for (var entry in workHistoryControllers) {
              for (var controller in entry.values) {
                controller.dispose();
              }
            }
            workHistoryControllers.clear();

            _initializeWorkHistoryControllers(profile.workHistory);
            if (mounted) setState(() {});
          }
        } else if (workHistoryControllers.isNotEmpty) {
          // If profile has no work history but controllers exist, clear them
          for (var entry in workHistoryControllers) {
            for (var controller in entry.values) {
              controller.dispose();
            }
          }
          workHistoryControllers.clear();
          if (mounted) setState(() {});
        }
      }
    });

    // Load initial profile if already available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedCandidateProfile.value != null && mounted) {
        final profile = controller.selectedCandidateProfile.value!;
        if (firstNameController.text.isEmpty) {
          firstNameController.text = profile.firstName;
        }
        if (lastNameController.text.isEmpty) {
          lastNameController.text = profile.lastName;
        }
        if (phoneController.text.isEmpty) {
          phoneController.text = profile.phone;
        }
        if (addressController.text.isEmpty) {
          addressController.text = profile.address;
        }

        // Load work history if available and controllers are empty
        if (profile.workHistory != null &&
            profile.workHistory!.isNotEmpty &&
            workHistoryControllers.isEmpty) {
          _initializeWorkHistoryControllers(profile.workHistory);
          setState(() {});
        }
      }
    });
  }

  void _initializeWorkHistoryControllers(
    List<Map<String, dynamic>>? workHistory,
  ) {
    if (workHistory == null) return;
    for (var work in workHistory) {
      workHistoryControllers.add({
        'company': TextEditingController(
          text: work['company']?.toString() ?? '',
        ),
        'position': TextEditingController(
          text: work['position']?.toString() ?? '',
        ),
        'description': TextEditingController(
          text: work['description']?.toString() ?? '',
        ),
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    for (var entry in workHistoryControllers) {
      for (var controller in entry.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addWorkHistoryEntry() {
    setState(() {
      workHistoryControllers.add({
        'company': TextEditingController(),
        'position': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeWorkHistoryEntry(int index) {
    setState(() {
      for (var controller in workHistoryControllers[index].values) {
        controller.dispose();
      }
      workHistoryControllers.removeAt(index);
    });
  }

  List<Map<String, dynamic>> _getWorkHistoryFromControllers() {
    return workHistoryControllers
        .map((controllers) {
          return {
            'company': controllers['company']!.text.trim(),
            'position': controllers['position']!.text.trim(),
            'description': controllers['description']!.text.trim(),
          };
        })
        .where(
          (work) =>
              work['company']!.isNotEmpty ||
              work['position']!.isNotEmpty ||
              work['description']!.isNotEmpty,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppAdminLayout(
      title: AppTexts.edit + ' ' + AppTexts.candidate,
      child: Obx(() {
        final candidate = controller.selectedCandidate.value;
        if (candidate == null) {
          return AppEmptyState(
            message: AppTexts.candidateNotFound,
            icon: Iconsax.profile_circle,
          );
        }

        return SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Name
              AppTextField(
                controller: firstNameController,
                labelText: AppTexts.firstName,
                showLabelAbove: true,
              ),
              AppSpacing.vertical(context, 0.02),

              // Last Name
              AppTextField(
                controller: lastNameController,
                labelText: AppTexts.lastName,
                showLabelAbove: true,
              ),
              AppSpacing.vertical(context, 0.02),

              // Phone
              AppTextField(
                controller: phoneController,
                labelText: AppTexts.phone,
                showLabelAbove: true,
                keyboardType: TextInputType.phone,
              ),
              AppSpacing.vertical(context, 0.02),

              // Address
              AppTextField(
                controller: addressController,
                labelText: AppTexts.address,
                showLabelAbove: true,
                maxLines: 3,
              ),
              AppSpacing.vertical(context, 0.03),

              // Work History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTexts.workHistory,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: _addWorkHistoryEntry,
                    icon: Icon(
                      Iconsax.add,
                      size: AppResponsive.iconSize(context),
                    ),
                    label: Text(AppTexts.addWorkHistory),
                  ),
                ],
              ),
              AppSpacing.vertical(context, 0.01),

              // Work History Entries
              ...workHistoryControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controllers = entry.value;
                return Padding(
                  padding: AppSpacing.all(context, factor: 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppTexts.workTitle} ${index + 1}',
                            style: AppTextStyles.bodyText(
                              context,
                            ).copyWith(fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            icon: const Icon(
                              Iconsax.trash,
                              color: AppColors.error,
                            ),
                            onPressed: () => _removeWorkHistoryEntry(index),
                          ),
                        ],
                      ),
                      AppSpacing.vertical(context, 0.01),
                      AppTextField(
                        controller: controllers['company']!,
                        labelText: AppTexts.company,
                        showLabelAbove: true,
                      ),
                      AppSpacing.vertical(context, 0.01),
                      AppTextField(
                        controller: controllers['position']!,
                        labelText: AppTexts.position,
                        showLabelAbove: true,
                      ),
                      AppSpacing.vertical(context, 0.01),
                      AppTextField(
                        controller: controllers['description']!,
                        labelText: AppTexts.description,
                        showLabelAbove: true,
                        maxLines: 3,
                      ),
                    ],
                  ),
                );
              }),

              AppSpacing.vertical(context, 0.03),

              // Error Message
              Obx(
                () => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: AppSpacing.vertical(context, 0.02).height!,
                        ),
                        child: AppErrorMessage(
                          message: controller.errorMessage.value,
                          icon: Iconsax.info_circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Save Button
              Obx(
                () => AppButton(
                  text: AppTexts.update,
                  onPressed: () {
                    final workHistory = _getWorkHistoryFromControllers();
                    controller.updateCandidateProfile(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      phone: phoneController.text.trim(),
                      address: addressController.text.trim(),
                      workHistory: workHistory.isEmpty ? null : workHistory,
                    );
                  },
                  isLoading: controller.isLoading.value,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
