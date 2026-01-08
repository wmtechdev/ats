import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class WorkHistoryEntry {
  final TextEditingController companyController;
  final TextEditingController positionController;
  final TextEditingController descriptionController;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final bool isOngoing;

  WorkHistoryEntry({
    required this.companyController,
    required this.positionController,
    required this.descriptionController,
    required this.fromDateController,
    required this.toDateController,
    this.isOngoing = false,
  });
}

class WorkHistorySectionWidget extends StatelessWidget {
  final List<WorkHistoryEntry> workHistoryEntries;
  final void Function(int index, bool isOngoing)? onOngoingChanged;
  final void Function(int index, String? company)? onCompanyChanged;
  final void Function(int index, String? position)? onPositionChanged;
  final void Function(int index, String? fromDate)? onFromDateChanged;
  final void Function(int index, String? toDate)? onToDateChanged;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final String? Function(int index, String fieldName)? getFieldError;
  final Rxn<String>? generalError;
  final bool hasError;

  const WorkHistorySectionWidget({
    super.key,
    required this.workHistoryEntries,
    this.onOngoingChanged,
    this.onCompanyChanged,
    this.onPositionChanged,
    this.onFromDateChanged,
    this.onToDateChanged,
    required this.onAdd,
    required this.onRemove,
    this.getFieldError,
    this.generalError,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get ProfileController if available (for candidate screens)
    ProfileController? profileController;
    try {
      profileController = Get.find<ProfileController>();
    } catch (e) {
      // ProfileController not available (e.g., in admin screens)
      profileController = null;
    }

    return AppExpandableSection(
      title: AppTexts.workHistory,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextButton(
              text: AppTexts.addWorkHistory,
              icon: Iconsax.add,
              onPressed: onAdd,
            ),
          ),
          ...workHistoryEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final workHistory = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: AppSpacing.vertical(context, 0.02).height!,
              ),
              child: Container(
                padding: AppSpacing.all(context, factor: 0.8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 1.5),
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
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
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(
                            Iconsax.trash,
                            color: AppColors.error,
                          ),
                          onPressed: () => onRemove(index),
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // Company
                    AppTextField(
                      controller: workHistory.companyController,
                      labelText: AppTexts.company,
                      showLabelAbove: true,
                      onChanged: (value) =>
                          onCompanyChanged?.call(index, value),
                    ),
                    if (getFieldError != null)
                      Obx(() {
                        final error = getFieldError!(index, 'company');
                        return error != null
                            ? Padding(
                                padding: EdgeInsets.only(
                                  top: AppSpacing.vertical(
                                    context,
                                    0.01,
                                  ).height!,
                                ),
                                child: AppErrorMessage(
                                  message: error,
                                  icon: Iconsax.info_circle,
                                ),
                              )
                            : const SizedBox.shrink();
                      })
                    else if (profileController != null)
                      Builder(
                        builder: (context) {
                          final controller = profileController!;
                          return Obx(
                            () =>
                                controller.getWorkHistoryFieldError(
                                      index,
                                      'company',
                                    ) !=
                                    null
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      top: AppSpacing.vertical(
                                        context,
                                        0.01,
                                      ).height!,
                                    ),
                                    child: AppErrorMessage(
                                      message:
                                          controller.getWorkHistoryFieldError(
                                            index,
                                            'company',
                                          ) ??
                                          '',
                                      icon: Iconsax.info_circle,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    AppSpacing.vertical(context, 0.01),

                    // Position
                    AppTextField(
                      controller: workHistory.positionController,
                      labelText: AppTexts.position,
                      showLabelAbove: true,
                      onChanged: (value) =>
                          onPositionChanged?.call(index, value),
                    ),
                    if (getFieldError != null)
                      Obx(() {
                        final error = getFieldError!(index, 'position');
                        return error != null
                            ? Padding(
                                padding: EdgeInsets.only(
                                  top: AppSpacing.vertical(
                                    context,
                                    0.01,
                                  ).height!,
                                ),
                                child: AppErrorMessage(
                                  message: error,
                                  icon: Iconsax.info_circle,
                                ),
                              )
                            : const SizedBox.shrink();
                      })
                    else if (profileController != null)
                      Builder(
                        builder: (context) {
                          final controller = profileController!;
                          return Obx(
                            () =>
                                controller.getWorkHistoryFieldError(
                                      index,
                                      'position',
                                    ) !=
                                    null
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      top: AppSpacing.vertical(
                                        context,
                                        0.01,
                                      ).height!,
                                    ),
                                    child: AppErrorMessage(
                                      message:
                                          controller.getWorkHistoryFieldError(
                                            index,
                                            'position',
                                          ) ??
                                          '',
                                      icon: Iconsax.info_circle,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    AppSpacing.vertical(context, 0.01),

                    // Description
                    AppTextField(
                      controller: workHistory.descriptionController,
                      labelText: AppTexts.description,
                      showLabelAbove: true,
                      maxLines: 3,
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // From Date
                    AppDatePicker(
                      controller: workHistory.fromDateController,
                      labelText: AppTexts.fromDate,
                      showLabelAbove: true,
                      hintText: 'YYYY-MM-DD',
                      lastDate: DateTime.now(), // Cannot be in future
                      onChanged: (value) =>
                          onFromDateChanged?.call(index, value),
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // Ongoing Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: workHistory.isOngoing,
                          onChanged: (value) {
                            onOngoingChanged?.call(index, value ?? false);
                          },
                        ),
                        Text(AppTexts.ongoing),
                      ],
                    ),
                    // To Date (only show if not ongoing)
                    if (!workHistory.isOngoing) ...[
                      AppSpacing.vertical(context, 0.01),
                      AppDatePicker(
                        controller: workHistory.toDateController,
                        labelText: AppTexts.toDate,
                        showLabelAbove: true,
                        hintText: 'YYYY-MM-DD',
                        onChanged: (value) =>
                            onToDateChanged?.call(index, value),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          if (generalError != null)
            Obx(
              () => generalError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: generalError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          else if (profileController != null)
            Builder(
              builder: (context) {
                final controller = profileController!;
                return Obx(
                  () => controller.workHistoryError.value != null
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: AppSpacing.vertical(context, 0.01).height!,
                          ),
                          child: AppErrorMessage(
                            message: controller.workHistoryError.value ?? '',
                            icon: Iconsax.info_circle,
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
    );
  }
}
