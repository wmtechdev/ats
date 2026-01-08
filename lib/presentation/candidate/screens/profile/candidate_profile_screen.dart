import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCandidateLayout(
      title: AppTexts.profile,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: const CandidateProfileForm(),
      ),
    );
  }
}
