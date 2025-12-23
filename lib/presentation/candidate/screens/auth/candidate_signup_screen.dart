import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/candidate_auth_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateSignUpScreen extends StatelessWidget {
  const CandidateSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandidateAuthController>();

    return AppAuthLayout(
      title: AppTexts.candidateSignUp,
      isLoginSelected: false,
      onLoginTap: () {
        Get.offNamed(AppConstants.routeLogin);
      },
      onSignUpTap: () {
        // Already on signup screen
      },
      formFields: [
        AppTextField(
          controller: controller.firstNameController,
          labelText: AppTexts.firstName,
          prefixIcon: Iconsax.user,
          onChanged: (value) {
            // Always validate on change to clear errors when user types
            // Use the value parameter directly instead of reading from controller
            controller.validateFirstName(value);
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
          onChanged: (value) {
            // Always validate on change to clear errors when user types
            // Use the value parameter directly instead of reading from controller
            controller.validateLastName(value);
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
          onChanged: (value) {
            // Always validate on change to clear errors when user types
            // Use the value parameter directly instead of reading from controller
            controller.validateEmail(value);
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
          onChanged: (value) {
            // Always validate on change to clear errors when user types
            // Use the value parameter directly instead of reading from controller
            controller.validatePassword(value);
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
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: controller.phoneController,
          labelText: AppTexts.phone,
          prefixIcon: Iconsax.call,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            // Always validate on change to clear errors when user types
            // Use the value parameter directly instead of reading from controller
            controller.validatePhone(value);
          },
        ),
        Obx(
          () => controller.phoneError.value != null
              ? AppErrorMessage(
                  message: controller.phoneError.value!,
                  icon: Iconsax.info_circle,
                  messageColor: AppColors.white,
                )
              : const SizedBox.shrink(),
        ),
        AppSpacing.vertical(context, 0.02),
        AppTextField(
          controller: controller.addressController,
          labelText: AppTexts.address,
          prefixIcon: Iconsax.location,
          maxLines: 3,
          onChanged: (value) {
            // Always validate on change to clear errors when user types
            // Use the value parameter directly instead of reading from controller
            controller.validateAddress(value);
          },
        ),
        Obx(
          () => controller.addressError.value != null
              ? AppErrorMessage(
                  message: controller.addressError.value!,
                  icon: Iconsax.info_circle,
                  messageColor: AppColors.white,
                )
              : const SizedBox.shrink(),
        ),
      ],
      errorMessage: Obx(
        () => controller.errorMessage.value.isNotEmpty
            ? AppErrorMessage(
                message: controller.errorMessage.value,
                icon: Iconsax.info_circle,
                messageColor: AppColors.white,
              )
            : const SizedBox.shrink(),
      ),
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
