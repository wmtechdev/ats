import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final controller = Get.find<ProfileController>();
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
    ever(controller.profile, (profile) {
      if (profile != null && mounted) {
        // Only update if controllers are empty or different
        if (firstNameController.text.isEmpty || firstNameController.text != profile.firstName) {
          firstNameController.text = profile.firstName;
        }
        if (lastNameController.text.isEmpty || lastNameController.text != profile.lastName) {
          lastNameController.text = profile.lastName;
        }
        if (phoneController.text.isEmpty || phoneController.text != profile.phone) {
          phoneController.text = profile.phone;
        }
        if (addressController.text.isEmpty || addressController.text != profile.address) {
          addressController.text = profile.address;
        }

        // Load work history
        if (profile.workHistory != null && profile.workHistory!.isNotEmpty) {
          // Always rebuild if work history exists and controllers are empty or lengths differ
          if (workHistoryControllers.isEmpty || 
              workHistoryControllers.length != profile.workHistory!.length) {
            // Clear existing and rebuild
            for (var entry in workHistoryControllers) {
              entry.values.forEach((controller) => controller.dispose());
            }
            workHistoryControllers.clear();
            
            controller.initializeWorkHistoryControllers(
              profile.workHistory,
              workHistoryControllers,
            );
            if (mounted) setState(() {});
          }
        } else if (workHistoryControllers.isNotEmpty) {
          // If profile has no work history but controllers exist, clear them
          for (var entry in workHistoryControllers) {
            entry.values.forEach((controller) => controller.dispose());
          }
          workHistoryControllers.clear();
          if (mounted) setState(() {});
        }
      }
    });

    // Load initial profile if already available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.profile.value != null && mounted) {
        final profile = controller.profile.value!;
        if (firstNameController.text.isEmpty) firstNameController.text = profile.firstName;
        if (lastNameController.text.isEmpty) lastNameController.text = profile.lastName;
        if (phoneController.text.isEmpty) phoneController.text = profile.phone;
        if (addressController.text.isEmpty) addressController.text = profile.address;
        
        // Load work history if available and controllers are empty
        if (profile.workHistory != null && 
            profile.workHistory!.isNotEmpty && 
            workHistoryControllers.isEmpty) {
          controller.initializeWorkHistoryControllers(
            profile.workHistory,
            workHistoryControllers,
          );
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    for (var entry in workHistoryControllers) {
      entry.values.forEach((controller) => controller.dispose());
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
      workHistoryControllers[index].values.forEach((controller) => controller.dispose());
      workHistoryControllers.removeAt(index);
      // Clear validation errors for this entry
      controller.clearWorkHistoryEntryErrors(index);
      // Re-validate all remaining work history entries to update indices
      final workHistory = controller.getWorkHistoryFromControllers(workHistoryControllers);
      controller.validateWorkHistory(workHistory.isEmpty ? null : workHistory);
    });
  }


  @override
  Widget build(BuildContext context) {
    return AppCandidateLayout(
      title: AppTexts.profile,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First Name
            AppTextField(
              controller: firstNameController,
              labelText: AppTexts.firstName,
              prefixIcon: Iconsax.user,
              onChanged: (value) => controller.validateFirstName(value),
            ),
            Obx(
              () => controller.firstNameError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(top: AppSpacing.vertical(context, 0.01).height!),
                      child: AppErrorMessage(
                        message: controller.firstNameError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),

            // Last Name
            AppTextField(
              controller: lastNameController,
              labelText: AppTexts.lastName,
              prefixIcon: Iconsax.user,
              onChanged: (value) => controller.validateLastName(value),
            ),
            Obx(
              () => controller.lastNameError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(top: AppSpacing.vertical(context, 0.01).height!),
                      child: AppErrorMessage(
                        message: controller.lastNameError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),

            // Phone
            AppTextField(
              controller: phoneController,
              labelText: AppTexts.phone,
              prefixIcon: Iconsax.call,
              keyboardType: TextInputType.phone,
              onChanged: (value) => controller.validatePhone(value),
            ),
            Obx(
              () => controller.phoneError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(top: AppSpacing.vertical(context, 0.01).height!),
                      child: AppErrorMessage(
                        message: controller.phoneError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),

            // Address
            AppTextField(
              controller: addressController,
              labelText: AppTexts.address,
              prefixIcon: Iconsax.location,
              maxLines: 3,
              onChanged: (value) => controller.validateAddress(value),
            ),
            Obx(
              () => controller.addressError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(top: AppSpacing.vertical(context, 0.01).height!),
                      child: AppErrorMessage(
                        message: controller.addressError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.03),

            // Work History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTexts.workHistory,
                  style: AppTextStyles.heading(context),
                ),
                TextButton.icon(
                  onPressed: _addWorkHistoryEntry,
                  icon: Icon(Iconsax.add, size: AppResponsive.iconSize(context)),
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
                          '${AppTexts.workHistory} ${index + 1}',
                          style: AppTextStyles.bodyText(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, color: AppColors.error),
                          onPressed: () => _removeWorkHistoryEntry(index),
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.01),
                    AppTextField(
                      controller: controllers['company']!,
                      labelText: AppTexts.company,
                      prefixIcon: Iconsax.building,
                      onChanged: (value) => controller.validateWorkHistoryField(index, 'company', value),
                    ),
                    Obx(
                      () => controller.getWorkHistoryFieldError(index, 'company') != null
                          ? Padding(
                              padding: EdgeInsets.only(top: AppSpacing.vertical(context, 0.01).height!),
                              child: AppErrorMessage(
                                message: controller.getWorkHistoryFieldError(index, 'company')!,
                                icon: Iconsax.info_circle,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    AppSpacing.vertical(context, 0.01),
                    AppTextField(
                      controller: controllers['position']!,
                      labelText: AppTexts.position,
                      prefixIcon: Iconsax.briefcase,
                      onChanged: (value) => controller.validateWorkHistoryField(index, 'position', value),
                    ),
                    Obx(
                      () => controller.getWorkHistoryFieldError(index, 'position') != null
                          ? Padding(
                              padding: EdgeInsets.only(top: AppSpacing.vertical(context, 0.01).height!),
                              child: AppErrorMessage(
                                message: controller.getWorkHistoryFieldError(index, 'position')!,
                                icon: Iconsax.info_circle,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    AppSpacing.vertical(context, 0.01),
                    AppTextField(
                      controller: controllers['description']!,
                      labelText: AppTexts.description,
                      prefixIcon: Iconsax.document_text,
                      maxLines: 3,
                    ),
                  ],
                ),
              );
            }),

            // Work History Error
            Obx(
              () => controller.workHistoryError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.vertical(context, 0.02).height!),
                      child: AppErrorMessage(
                        message: controller.workHistoryError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            AppSpacing.vertical(context, 0.03),

            // Error Message
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.vertical(context, 0.02).height!),
                      child: AppErrorMessage(
                        message: controller.errorMessage.value,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Save Button
            Obx(() => AppButton(
                  text: AppTexts.saveProfile,
                  onPressed: () {
                    // Validate all work history entries before submitting
                    final workHistory = controller.getWorkHistoryFromControllers(workHistoryControllers);
                    controller.validateWorkHistory(workHistory.isEmpty ? null : workHistory);
                    
                    controller.createOrUpdateProfile(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      workHistory: workHistory.isEmpty ? null : workHistory,
                    );
                  },
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }
}
