import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_navigation/app_navigation.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is fresh - this simulates app restart behavior after sign-out
    // The controller is deleted on sign-out, so Get.find() will create a fresh instance via lazyPut
    final controller = Get.find<AdminAuthController>();
    
    // Use controller instance as key to force widget recreation when controller is recreated
    final controllerKey = controller.hashCode;

    return AppAuthLayout(
      title: AppTexts.adminLogin,
      isLoginSelected: true,
      onLoginTap: () {
        // Already on login screen
      },
      onSignUpTap: () {
        AppNavigation.toNamedWithFade(AppConstants.routeAdminSignUp);
      },
      formFields: [
        AppTextField(
          key: ValueKey('admin_login_email_$controllerKey'), // Force recreation when controller changes
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
          key: ValueKey('admin_login_password_$controllerKey'), // Force recreation when controller changes
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
          text: AppTexts.login,
          onPressed: controller.signIn,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }
}
