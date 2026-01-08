import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/profile_constants.dart';

class SpecialtySection extends StatelessWidget {
  final String? selectedProfession;
  final List<String> selectedSpecialties;
  final void Function(String?)? onProfessionChanged;
  final void Function(List<String> specialties)? onSpecialtiesChanged;
  final Rxn<String>? professionError;
  final Rxn<String>? specialtiesError;
  final bool hasError;

  const SpecialtySection({
    super.key,
    this.selectedProfession,
    required this.selectedSpecialties,
    this.onProfessionChanged,
    this.onSpecialtiesChanged,
    this.professionError,
    this.specialtiesError,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.specialty,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profession Dropdown
          AppDropDownField<String>(
            value: selectedProfession,
            labelText: '${AppTexts.profession}(*)',
            showLabelAbove: true,
            items: ProfileConstants.professions
                .map(
                  (profession) => DropdownMenuItem<String>(
                    value: profession,
                    child: Text(profession),
                  ),
                )
                .toList(),
            onChanged: onProfessionChanged ?? (value) {},
          ),
          if (professionError != null)
            Obx(
              () => professionError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: professionError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // Specialties (Tag Input - Multiple)
          AppTagInput(
            tags: selectedSpecialties,
            labelText: '${AppTexts.specialties}(*)',
            showLabelAbove: true,
            hintText: 'Type specialty and press Enter',
            onTagsChanged: (tags) {
              onSpecialtiesChanged?.call(tags);
            },
          ),
          if (specialtiesError != null)
            Obx(
              () => specialtiesError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: specialtiesError!.value!,
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
