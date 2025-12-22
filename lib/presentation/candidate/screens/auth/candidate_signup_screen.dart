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

class CandidateSignUpScreen extends StatelessWidget {
  const CandidateSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(title: AppTexts.signUp),
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppTexts.signUp,
                style: AppTextStyles.headline(context),
              ),
              AppSpacing.vertical(context, 0.04),
              AppTextField(
                controller: firstNameController,
                labelText: AppTexts.firstName,
                prefixIcon: Iconsax.user,
              ),
              AppSpacing.vertical(context, 0.02),
              AppTextField(
                controller: lastNameController,
                labelText: AppTexts.lastName,
                prefixIcon: Iconsax.user,
              ),
              AppSpacing.vertical(context, 0.02),
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
                    text: AppTexts.signUp,
                    onPressed: () {
                      controller.signUp(
                        email: emailController.text,
                        password: passwordController.text,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                      );
                    },
                    isLoading: controller.isLoading.value,
                  )),
              AppSpacing.vertical(context, 0.02),
              AppTextButton(
                text: AppTexts.alreadyHaveAccount,
                onPressed: () {
                  Get.toNamed(AppConstants.routeLogin);
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

