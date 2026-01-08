import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class EducationEntry {
  final TextEditingController institutionController;
  final TextEditingController degreeController;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final bool isOngoing;
  final Rxn<String>? institutionError;
  final Rxn<String>? degreeError;
  final Rxn<String>? fromDateError;
  final Rxn<String>? toDateError;

  EducationEntry({
    required this.institutionController,
    required this.degreeController,
    required this.fromDateController,
    required this.toDateController,
    this.isOngoing = false,
    this.institutionError,
    this.degreeError,
    this.fromDateError,
    this.toDateError,
  });
}

class EducationSection extends StatelessWidget {
  final List<EducationEntry> educationEntries;
  final void Function(int index, bool isOngoing)? onOngoingChanged;
  final void Function(int index, String? institution)? onInstitutionChanged;
  final void Function(int index, String? degree)? onDegreeChanged;
  final void Function(int index, String? fromDate)? onFromDateChanged;
  final void Function(int index, String? toDate)? onToDateChanged;
  final void Function()? onAddEducation;
  final void Function(int index)? onRemoveEducation;
  final String? Function(int index, String fieldName)? getFieldError;
  final Rxn<String>? generalError;
  final bool hasError;

  const EducationSection({
    super.key,
    required this.educationEntries,
    this.onOngoingChanged,
    this.onInstitutionChanged,
    this.onDegreeChanged,
    this.onFromDateChanged,
    this.onToDateChanged,
    this.onAddEducation,
    this.onRemoveEducation,
    this.getFieldError,
    this.generalError,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.education,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextButton(
              text: AppTexts.addEducation,
              icon: Iconsax.add,
              onPressed: onAddEducation,
            ),
          ),
          ...educationEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final education = entry.value;
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
                          '${AppTexts.education} ${index + 1}',
                          style: AppTextStyles.bodyText(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(
                            Iconsax.trash,
                            color: AppColors.error,
                          ),
                          onPressed: () => onRemoveEducation?.call(index),
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // Institution Name
                    AppTextField(
                      controller: education.institutionController,
                      labelText: AppTexts.institutionName,
                      showLabelAbove: true,
                      onChanged: (value) =>
                          onInstitutionChanged?.call(index, value),
                    ),
                    if (getFieldError != null)
                      Obx(() {
                        final error = getFieldError!(index, 'institutionName');
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
                      }),
                    AppSpacing.vertical(context, 0.01),

                    // Degree
                    AppTextField(
                      controller: education.degreeController,
                      labelText: AppTexts.degree,
                      showLabelAbove: true,
                      onChanged: (value) => onDegreeChanged?.call(index, value),
                    ),
                    if (getFieldError != null)
                      Obx(() {
                        final error = getFieldError!(index, 'degree');
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
                      }),
                    AppSpacing.vertical(context, 0.01),

                    // From Date
                    AppDatePicker(
                      controller: education.fromDateController,
                      labelText: AppTexts.fromDate,
                      showLabelAbove: true,
                      hintText: 'YYYY-MM-DD',
                      lastDate: DateTime.now(), // Cannot be in future
                      onChanged: (value) =>
                          onFromDateChanged?.call(index, value),
                    ),
                    if (education.fromDateError != null)
                      Obx(
                        () => education.fromDateError!.value != null
                            ? Padding(
                                padding: EdgeInsets.only(
                                  top: AppSpacing.vertical(
                                    context,
                                    0.01,
                                  ).height!,
                                ),
                                child: AppErrorMessage(
                                  message: education.fromDateError!.value!,
                                  icon: Iconsax.info_circle,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    AppSpacing.vertical(context, 0.01),

                    // Ongoing Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: education.isOngoing,
                          onChanged: (value) {
                            onOngoingChanged?.call(index, value ?? false);
                          },
                        ),
                        Text(AppTexts.ongoing),
                      ],
                    ),
                    // To Date (only show if not ongoing)
                    if (!education.isOngoing) ...[
                      AppSpacing.vertical(context, 0.01),
                      AppDatePicker(
                        controller: education.toDateController,
                        labelText: AppTexts.toDate,
                        showLabelAbove: true,
                        hintText: 'YYYY-MM-DD',
                        onChanged: (value) =>
                            onToDateChanged?.call(index, value),
                      ),
                      if (education.toDateError != null)
                        Obx(
                          () => education.toDateError!.value != null
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: AppSpacing.vertical(
                                      context,
                                      0.01,
                                    ).height!,
                                  ),
                                  child: AppErrorMessage(
                                    message: education.toDateError!.value!,
                                    icon: Iconsax.info_circle,
                                  ),
                                )
                              : const SizedBox.shrink(),
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
            ),
        ],
      ),
    );
  }
}
