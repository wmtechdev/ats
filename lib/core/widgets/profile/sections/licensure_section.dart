import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/profile_constants.dart';

class LicensureSection extends StatelessWidget {
  final String? selectedState;
  final TextEditingController npiController;
  final void Function(String?)? onStateChanged;
  final Rxn<String>? stateError;
  final bool hasError;

  const LicensureSection({
    super.key,
    this.selectedState,
    required this.npiController,
    this.onStateChanged,
    this.stateError,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.licensure,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // State Dropdown
          AppDropDownField<String>(
            value: selectedState,
            labelText: '${AppTexts.state}(*)',
            showLabelAbove: true,
            items: ProfileConstants.usStates
                .map(
                  (state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  ),
                )
                .toList(),
            onChanged: onStateChanged ?? (value) {},
          ),
          if (stateError != null)
            Obx(
              () => stateError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: stateError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // NPI
          AppTextField(
            controller: npiController,
            labelText: AppTexts.npi,
            showLabelAbove: true,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
