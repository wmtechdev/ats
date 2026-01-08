import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class PhoneEntry {
  final TextEditingController countryCodeController;
  final TextEditingController numberController;
  final Rxn<String>? countryCodeError;
  final Rxn<String>? numberError;

  PhoneEntry({
    required this.countryCodeController,
    required this.numberController,
    this.countryCodeError,
    this.numberError,
  });
}

class PhonesSection extends StatelessWidget {
  final List<PhoneEntry> phoneEntries;
  final void Function(int index, String? countryCode)? onCountryCodeChanged;
  final void Function(int index, String? number)? onNumberChanged;
  final void Function()? onAddPhone;
  final void Function(int index)? onRemovePhone;
  final bool hasError;

  const PhonesSection({
    super.key,
    required this.phoneEntries,
    this.onCountryCodeChanged,
    this.onNumberChanged,
    this.onAddPhone,
    this.onRemovePhone,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.phones,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (phoneEntries.length < 2)
            Align(
              alignment: Alignment.centerLeft,
              child: AppTextButton(
                text: AppTexts.addPhone,
                icon: Iconsax.add,
                onPressed: onAddPhone,
              ),
            ),
          ...phoneEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final phone = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: AppSpacing.vertical(context, 0.02).height!,
              ),
              child: Container(
                padding: AppSpacing.all(context, factor: 0.8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppResponsive.radius(context, factor: 5),
                  ),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppTexts.phone} ${index + 1}',
                          style: AppTextStyles.bodyText(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (phoneEntries.length > 1)
                          IconButton(
                            icon: const Icon(
                              Iconsax.trash,
                              color: AppColors.error,
                            ),
                            onPressed: () => onRemovePhone?.call(index),
                          ),
                      ],
                    ),
                    AppSpacing.vertical(context, 0.01),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppCountryCodePicker(
                            initialValue: phone.countryCodeController.text.isEmpty
                                ? '+1'
                                : phone.countryCodeController.text,
                            labelText: AppTexts.countryCode,
                            showLabelAbove: true,
                            onChanged: (countryCode) {
                              phone.countryCodeController.text = countryCode;
                              onCountryCodeChanged?.call(index, countryCode);
                            },
                          ),
                        ),
                        AppSpacing.horizontal(context, 0.02),
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            controller: phone.numberController,
                            labelText: '${AppTexts.number}(*)',
                            showLabelAbove: true,
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => onNumberChanged?.call(index, value),
                          ),
                        ),
                      ],
                    ),
                    if (phone.numberError != null)
                      Obx(
                        () => phone.numberError!.value != null
                            ? Padding(
                                padding: EdgeInsets.only(
                                  top: AppSpacing.vertical(context, 0.01).height!,
                                ),
                                child: AppErrorMessage(
                                  message: phone.numberError!.value!,
                                  icon: Iconsax.info_circle,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
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
