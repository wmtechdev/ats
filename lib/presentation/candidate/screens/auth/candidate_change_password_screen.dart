import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/candidate_auth_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateChangePasswordScreen extends StatefulWidget {
  const CandidateChangePasswordScreen({super.key});

  @override
  State<CandidateChangePasswordScreen> createState() =>
      _CandidateChangePasswordScreenState();
}

class _CandidateChangePasswordScreenState
    extends State<CandidateChangePasswordScreen> {
  @override
  void initState() {
    super.initState();
    // Reset change password state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CandidateAuthController>();
      controller.resetChangePasswordState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandidateAuthController>();

    return AppCandidateLayout(
      title: AppTexts.changePasswordTitle,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.currentPasswordController,
              labelText: '${AppTexts.currentPassword}(*)',
              showLabelAbove: true,
              obscureText: true,
              onChanged: (value) {
                controller.validateCurrentPassword(value);
              },
            ),
            Obx(
              () => controller.currentPasswordError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: controller.currentPasswordError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.newPasswordController,
              labelText: '${AppTexts.newPassword}(*)',
              showLabelAbove: true,
              obscureText: true,
              onChanged: (value) {
                controller.validateNewPassword(value);
                // Re-validate confirm password when new password changes
                if (controller.confirmPasswordValue.value.isNotEmpty) {
                  controller.validateConfirmPassword(
                    controller.confirmPasswordValue.value,
                  );
                }
              },
            ),
            Obx(
              () => controller.newPasswordValue.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppPasswordStrengthIndicator(
                        password: controller.newPasswordValue.value,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => controller.newPasswordError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: controller.newPasswordError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.confirmPasswordController,
              labelText: '${AppTexts.confirmPassword}(*)',
              showLabelAbove: true,
              obscureText: true,
              onChanged: (value) {
                controller.validateConfirmPassword(value);
              },
            ),
            Obx(
              () => controller.confirmPasswordError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: controller.confirmPasswordError.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.03),
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSpacing.vertical(context, 0.02).height!,
                      ),
                      child: AppErrorMessage(
                        message: controller.errorMessage.value,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => AppButton(
                text: controller.isLoading.value
                    ? AppTexts.passwordChanging
                    : AppTexts.changePassword,
                onPressed: controller.performChangePassword,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
