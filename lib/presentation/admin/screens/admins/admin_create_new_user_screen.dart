import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/presentation/admin/controllers/admin_create_new_user_controller.dart';

class AdminCreateNewUserScreen extends StatelessWidget {
  const AdminCreateNewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCreateNewUserController>();

    return AppAdminLayout(
      title: AppTexts.createNewUser,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.nameController,
              labelText: AppTexts.fullName,
              prefixIcon: Iconsax.user,
              onChanged: (value) {
                controller.validateName(value);
              },
            ),
            Obx(
              () => controller.nameError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.nameError.value!,
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
              prefixIcon: Iconsax.sms,
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
              prefixIcon: Iconsax.lock,
              obscureText: true,
              onChanged: (value) {
                controller.validatePassword(value);
              },
            ),
            Obx(
              () => controller.passwordValue.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppPasswordStrengthIndicator(
                        password: controller.passwordValue.value,
                      ),
                    )
                  : const SizedBox.shrink(),
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
            AppDropDownField<String>(
              value: controller.roleValue.value,
              labelText: AppTexts.role,
              prefixIcon: Iconsax.user_tag,
              errorText: controller.roleError.value,
              items: [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text(
                    AppTexts.admin,
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
                DropdownMenuItem(
                  value: 'recruiter',
                  child: Text(
                    AppTexts.recruiter,
                    style: AppTextStyles.bodyText(context),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setRole(value);
                }
              },
            ),
            Obx(
              () => controller.roleError.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppResponsive.screenHeight(context) * 0.01,
                      ),
                      child: AppErrorMessage(
                        message: controller.roleError.value!,
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
                text: AppTexts.createUser,
                onPressed: controller.createAdmin,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
