import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/auth_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_navigation/app_navigation.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateSignUpScreen extends StatelessWidget {
  const CandidateSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return AppAuthLayout(
      title: AppTexts.candidateSignUp,
      isLoginSelected: false,
      onLoginTap: () {
        AppNavigation.toNamedWithFade(AppConstants.routeLogin);
      },
      onSignUpTap: () {
        // Already on signup screen
      },
      formFields: [
        AppTextField(
          controller: controller.firstNameController,
          labelText: AppTexts.firstName,
          prefixIcon: Iconsax.user,
          onChanged: (_) {
            if (controller.firstNameError.value != null) {
              controller.validateFirstName(controller.firstNameController.text);
            }
          },
        ),
        Obx(
          () => controller.firstNameError.value != null
              ? AppErrorMessage(
                  message: controller.firstNameError.value!,
                  icon: Iconsax.info_circle,
                  messageColor: AppColors.white,
                )
              : const SizedBox.shrink(),
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: controller.lastNameController,
          labelText: AppTexts.lastName,
          prefixIcon: Iconsax.user,
          onChanged: (_) {
            if (controller.lastNameError.value != null) {
              controller.validateLastName(controller.lastNameController.text);
            }
          },
        ),
        Obx(
          () => controller.lastNameError.value != null
              ? AppErrorMessage(
                  message: controller.lastNameError.value!,
                  icon: Iconsax.info_circle,
                  messageColor: AppColors.white,
                )
              : const SizedBox.shrink(),
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: controller.emailController,
          labelText: AppTexts.email,
          prefixIcon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (controller.emailError.value != null) {
              controller.validateEmail(controller.emailController.text);
            }
          },
        ),
        Obx(
          () => controller.emailError.value != null
              ? AppErrorMessage(
                  message: controller.emailError.value!,
                  icon: Iconsax.info_circle,
                  messageColor: AppColors.white,
                )
              : const SizedBox.shrink(),
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: controller.passwordController,
          labelText: AppTexts.password,
          prefixIcon: Iconsax.lock,
          obscureText: true,
          onChanged: (_) {
            if (controller.passwordError.value != null) {
              controller.validatePassword(controller.passwordController.text);
            }
          },
        ),
        Obx(
          () => controller.passwordError.value != null
              ? AppErrorMessage(
                  message: controller.passwordError.value!,
                  icon: Iconsax.info_circle,
                  messageColor: AppColors.white,
                )
              : const SizedBox.shrink(),
        ),
      ],
      actionButton: Obx(
        () => AppButton(
          text: AppTexts.signUp,
          onPressed: controller.signUp,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }
}
