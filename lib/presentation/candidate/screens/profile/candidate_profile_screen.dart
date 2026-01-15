import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  // Use GlobalKey to preserve form state across rebuilds
  // This is the simplest and most reliable solution
  final _formKey = GlobalKey(debugLabel: 'candidate-profile-form');
  Widget? _cachedScrollView;

  @override
  Widget build(BuildContext context) {
    // Cache the scroll view to prevent recreation
    _cachedScrollView ??= SingleChildScrollView(
      key: const ValueKey('profile-scroll-view'),
      padding: AppSpacing.padding(context),
      child: CandidateProfileForm(key: _formKey), // Use GlobalKey to preserve state
    );
    
    return AppCandidateLayout(
      key: const ValueKey('candidate-profile-screen-layout'),
      title: AppTexts.profile,
      child: _cachedScrollView!,
    );
  }
}
