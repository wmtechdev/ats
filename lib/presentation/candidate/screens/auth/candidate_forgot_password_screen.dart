import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/candidate_auth_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateForgotPasswordScreen extends StatefulWidget {
  const CandidateForgotPasswordScreen({super.key});

  @override
  State<CandidateForgotPasswordScreen> createState() =>
      _CandidateForgotPasswordScreenState();
}

class _CandidateForgotPasswordScreenState
    extends State<CandidateForgotPasswordScreen> {
  @override
  void initState() {
    super.initState();
    // Reset forgot password state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CandidateAuthController>();
      controller.resetForgotPasswordState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandidateAuthController>();

    return AppAuthLayout(
      title: AppTexts.forgotPasswordTitle,
      isLoginSelected: true,
      onLoginTap: () {
        Get.offNamed(AppConstants.routeLogin);
      },
      onSignUpTap: () {
        Get.offNamed(AppConstants.routeSignUp);
      },
      formFields: [
        Text(
          AppTexts.forgotPasswordDescription,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(color: AppColors.white),
        ),
        AppSpacing.vertical(context, 0.03),
        AppTextField(
          controller: controller.forgotPasswordEmailController,
          labelText: AppTexts.email,
          prefixIcon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            controller.validateForgotPasswordEmail(value);
          },
        ),
        Obx(
          () => controller.forgotPasswordEmailError.value != null
              ? Padding(
                  padding: EdgeInsets.only(
                    top: AppSpacing.vertical(context, 0.01).height!,
                  ),
                  child: AppErrorMessage(
                    message: controller.forgotPasswordEmailError.value!,
                    icon: Iconsax.info_circle,
                    messageColor: AppColors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        AppSpacing.vertical(context, 0.02),
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
          text: controller.isLoading.value
              ? AppTexts.passwordResetSending
              : AppTexts.sendResetLink,
          onPressed: controller.sendPasswordResetEmail,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
