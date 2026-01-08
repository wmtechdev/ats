import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class CertificationEntry {
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final bool hasNoExpiry;

  CertificationEntry({
    required this.nameController,
    required this.expiryController,
    this.hasNoExpiry = false,
  });
}

class CertificationsSection extends StatelessWidget {
  final List<CertificationEntry> certificationEntries;
  final void Function(int index, bool hasNoExpiry)? onNoExpiryChanged;
  final void Function()? onAddCertification;
  final void Function(int index)? onRemoveCertification;
  final bool hasError;

  const CertificationsSection({
    super.key,
    required this.certificationEntries,
    this.onNoExpiryChanged,
    this.onAddCertification,
    this.onRemoveCertification,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.certifications,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextButton(
              text: AppTexts.addCertification,
              icon: Iconsax.add,
              onPressed: onAddCertification,
            ),
          ),
          ...certificationEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final certification = entry.value;
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
                          '${AppTexts.certifications} ${index + 1}',
                          style: AppTextStyles.bodyText(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(
                            Iconsax.trash,
                            color: AppColors.error,
                          ),
                          onPressed: () => onRemoveCertification?.call(index),
                        ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // Name
                    AppTextField(
                      controller: certification.nameController,
                      labelText: AppTexts.certificationName,
                      showLabelAbove: true,
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // No Expiry Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: certification.hasNoExpiry,
                          onChanged: (value) {
                            onNoExpiryChanged?.call(index, value ?? false);
                          },
                        ),
                        Text('No Expiry'),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.01),

                    // Expiry
                    if (!certification.hasNoExpiry) ...[
                      AppSpacing.vertical(context, 0.01),
                      AppDatePicker(
                        controller: certification.expiryController,
                        labelText: AppTexts.expiry,
                        showLabelAbove: true,
                        hintText: 'MM/YYYY',
                        monthYearOnly: true,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
