import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/auth/components/app_navigation_chip.dart';
import 'package:ats/core/widgets/auth/components/app_auth_logo.dart';
import 'package:ats/core/widgets/auth/components/app_auth_title.dart';
import 'package:ats/core/widgets/auth/forms/app_auth_form_content.dart';
import 'package:ats/core/widgets/auth/layout/app_auth_container.dart';
import 'package:ats/core/widgets/common/layout/app_wmsols_footer.dart';

class AppAuthLayout extends StatelessWidget {
  final String title;
  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;
  final List<Widget> formFields;
  final Widget actionButton;
  final Widget? errorMessage;
  final bool showNavigationChip;

  const AppAuthLayout({
    super.key,
    required this.title,
    required this.isLoginSelected,
    required this.onLoginTap,
    required this.onSignUpTap,
    required this.formFields,
    required this.actionButton,
    this.errorMessage,
    this.showNavigationChip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                      if (showNavigationChip)
                        AppNavigationChip(
                          firstLabel: AppTexts.login,
                          secondLabel: AppTexts.signUp,
                          isFirstSelected: isLoginSelected,
                          onFirstTap: onLoginTap,
                          onSecondTap: onSignUpTap,
                        ),
                      if (showNavigationChip) AppSpacing.vertical(context, 0.02),
                      AppAuthTitle(title: title),
                      AppSpacing.vertical(context, 0.04),
                      AppAuthFormContent(
                        isLoginSelected: isLoginSelected,
                        formFields: formFields,
                        actionButton: actionButton,
                        errorMessage: errorMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const AppWMSolsFooter(),
          ],
        ),
      ),
    );
  }
}
