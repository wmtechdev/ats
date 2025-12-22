import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/auth/app_navigation_chip.dart';
import 'package:ats/core/widgets/auth/app_auth_logo.dart';
import 'package:ats/core/widgets/auth/app_auth_title.dart';
import 'package:ats/core/widgets/auth/app_auth_form_content.dart';
import 'package:ats/core/widgets/auth/app_auth_container.dart';

class AppAuthLayout extends StatelessWidget {
  final String title;
  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;
  final List<Widget> formFields;
  final Widget actionButton;

  const AppAuthLayout({
    super.key,
    required this.title,
    required this.isLoginSelected,
    required this.onLoginTap,
    required this.onSignUpTap,
    required this.formFields,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: AppAuthContainer(
          child: Container(
            padding: AppSpacing.all(context),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppAuthLogo(),
                AppSpacing.vertical(context, 0.02),
                AppNavigationChip(
                  firstLabel: AppTexts.login,
                  secondLabel: AppTexts.signUp,
                  isFirstSelected: isLoginSelected,
                  onFirstTap: onLoginTap,
                  onSecondTap: onSignUpTap,
                ),
                AppSpacing.vertical(context, 0.02),
                AppAuthTitle(title: title),
                AppSpacing.vertical(context, 0.04),
                AppAuthFormContent(
                  isLoginSelected: isLoginSelected,
                  formFields: formFields,
                  actionButton: actionButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
