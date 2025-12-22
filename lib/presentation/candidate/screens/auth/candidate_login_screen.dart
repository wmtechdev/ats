import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/auth_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateLoginScreen extends StatelessWidget {
  const CandidateLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(title: AppTexts.login),
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppTexts.login,
                style: AppTextStyles.headline(context),
              ),
              AppSpacing.vertical(context, 0.04),
              AppTextField(
                controller: emailController,
                labelText: AppTexts.email,
                prefixIcon: Iconsax.sms,
              ),
              AppSpacing.vertical(context, 0.02),
              AppTextField(
                controller: passwordController,
                labelText: AppTexts.password,
                prefixIcon: Iconsax.lock,
                obscureText: true,
              ),
              AppSpacing.vertical(context, 0.03),
              Obx(() => AppButton(
                    text: AppTexts.login,
                    onPressed: () {
                      controller.signIn(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    isLoading: controller.isLoading.value,
                  )),
              AppSpacing.vertical(context, 0.02),
              AppTextButton(
                text: AppTexts.forgotPassword,
                onPressed: () {
                  Get.toNamed(AppConstants.routeForgotPassword);
                },
              ),
              AppSpacing.vertical(context, 0.02),
              AppTextButton(
                text: AppTexts.dontHaveAccount,
                onPressed: () {
                  Get.toNamed(AppConstants.routeSignUp);
                },
              ),
              Obx(() => AppErrorMessage(
                    message: controller.errorMessage.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

