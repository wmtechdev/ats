import 'package:flutter/material.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class BackgroundHistorySection extends StatelessWidget {
  final String? liabilityAction;
  final String? licenseAction;
  final String? previouslyTraveled;
  final String? terminatedFromAssignment;
  final void Function(String?)? onLiabilityActionChanged;
  final void Function(String?)? onLicenseActionChanged;
  final void Function(String?)? onPreviouslyTraveledChanged;
  final void Function(String?)? onTerminatedFromAssignmentChanged;
  final bool hasError;

  const BackgroundHistorySection({
    super.key,
    this.liabilityAction,
    this.licenseAction,
    this.previouslyTraveled,
    this.terminatedFromAssignment,
    this.onLiabilityActionChanged,
    this.onLicenseActionChanged,
    this.onPreviouslyTraveledChanged,
    this.onTerminatedFromAssignmentChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.backgroundHistory,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Liability Action Question
          _buildYesNoQuestion(
            context,
            AppTexts.liabilityAction,
            liabilityAction,
            onLiabilityActionChanged,
          ),
          AppSpacing.vertical(context, 0.02),

          // License Action Question
          _buildYesNoQuestion(
            context,
            AppTexts.licenseAction,
            licenseAction,
            onLicenseActionChanged,
          ),
          AppSpacing.vertical(context, 0.02),

          // Previously Traveled Question
          _buildYesNoQuestion(
            context,
            AppTexts.previouslyTraveled,
            previouslyTraveled,
            onPreviouslyTraveledChanged,
          ),
          AppSpacing.vertical(context, 0.02),

          // Terminated From Assignment Question
          _buildYesNoQuestion(
            context,
            AppTexts.terminatedFromAssignment,
            terminatedFromAssignment,
            onTerminatedFromAssignmentChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion(
    BuildContext context,
    String question,
    String? value,
    void Function(String?)? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        AppSpacing.vertical(context, 0.01),
        AppDropDownField<String>(
          value: value,
          labelText: AppTexts.select,
          showLabelAbove: true,
          items: [
            DropdownMenuItem<String>(
              value: AppTexts.yes,
              child: Text(AppTexts.yes),
            ),
            DropdownMenuItem<String>(
              value: AppTexts.no,
              child: Text(AppTexts.no),
            ),
          ],
          onChanged: onChanged ?? (value) {},
        ),
      ],
    );
  }
}
