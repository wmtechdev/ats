import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Local controllers that we manage - these won't be disposed unexpectedly
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  AdminAuthController? _authController;
  
  @override
  void initState() {
    super.initState();
    // Create local controllers that we control
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _syncWithAuthController();
  }
  
  void _syncWithAuthController() {
    try {
      final controller = Get.find<AdminAuthController>();
      _authController = controller;
      
      // Sync local controllers with auth controller's values initially
      // After this, onChanged callbacks will keep them in sync
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _authController != null) {
          if (_emailController.text != _authController!.emailValue.value) {
            _emailController.text = _authController!.emailValue.value;
          }
          if (_passwordController.text != _authController!.passwordValue.value) {
            _passwordController.text = _authController!.passwordValue.value;
          }
        }
      });
    } catch (e) {
      // Controller not found yet, will be created by GetX
      _authController = null;
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get or create auth controller
    try {
      _authController ??= Get.find<AdminAuthController>();
    } catch (e) {
      // Controller not found, return empty
      return const SizedBox.shrink();
    }
    
    final controller = _authController!;
    
    return AppAuthLayout(
      title: AppTexts.adminLogin,
      isLoginSelected: true,
      showNavigationChip: false,
      onLoginTap: () {
        // Already on login screen
      },
      onSignUpTap: () {
        // Signup removed - admins are created by other admins
      },
      formFields: [
        AppTextField(
          key: const ValueKey('admin-login-email'),
          controller: _emailController,
          labelText: AppTexts.email,
          prefixIcon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            // Update auth controller's value and validate
            controller.emailValue.value = value;
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
          key: const ValueKey('admin-login-password'),
          controller: _passwordController,
          labelText: AppTexts.password,
          prefixIcon: Iconsax.lock,
          obscureText: true,
          onChanged: (value) {
            // Update auth controller's value and validate
            controller.passwordValue.value = value;
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
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
