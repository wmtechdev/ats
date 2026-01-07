import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/presentation/admin/controllers/admin_create_candidate_controller.dart';

class AdminCreateCandidateScreen extends StatelessWidget {
  const AdminCreateCandidateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCreateCandidateController>();

    return AppAdminLayout(
      title: AppTexts.createCandidate,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.firstNameController,
              labelText: AppTexts.firstName,
              showLabelAbove: true,
              onChanged: (value) {
                controller.validateFirstName(value);
              },
            ),
            Obx(
              () => controller.firstNameError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.firstNameError.value!,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.lastNameController,
              labelText: AppTexts.lastName,
              showLabelAbove: true,
              onChanged: (value) {
                controller.validateLastName(value);
              },
            ),
            Obx(
              () => controller.lastNameError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.lastNameError.value!,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.emailController,
              labelText: AppTexts.email,
              showLabelAbove: true,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                controller.validateEmail(value);
              },
            ),
            Obx(
              () => controller.emailError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.emailError.value!,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.passwordController,
              labelText: AppTexts.password,
              showLabelAbove: true,
              obscureText: true,
              onChanged: (value) {
                controller.validatePassword(value);
              },
            ),
            Obx(
              () => controller.passwordError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.passwordError.value!,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.phoneController,
              labelText: AppTexts.phone,

              keyboardType: TextInputType.phone,
              onChanged: (value) {
                controller.validatePhone(value);
              },
            ),
            Obx(
              () => controller.phoneError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.phoneError.value!,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.02),
            AppTextField(
              controller: controller.addressController,
              labelText: AppTexts.address,
              showLabelAbove: true,
              maxLines: 3,
              onChanged: (value) {
                controller.validateAddress(value);
              },
            ),
            Obx(
              () => controller.addressError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.addressError.value!,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AppSpacing.vertical(context, 0.03),
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: AppResponsive.screenHeight(context) * 0.02,
                      ),
                      child: AppErrorMessage(
                        message: controller.errorMessage.value,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => AppButton(
                text: AppTexts.createCandidate,
                onPressed: controller.createCandidate,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
