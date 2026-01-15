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

class AdminCreateNewUserScreen extends StatefulWidget {
  const AdminCreateNewUserScreen({super.key});

  @override
  State<AdminCreateNewUserScreen> createState() => _AdminCreateNewUserScreenState();
}

class _AdminCreateNewUserScreenState extends State<AdminCreateNewUserScreen> {
  late final AdminCreateNewUserController _controller;
  Widget? _cachedForm;
  final _formKey = GlobalKey(debugLabel: 'admin-create-user-form');

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminCreateNewUserController>();
  }

  @override
  Widget build(BuildContext context) {
    _cachedForm ??= SingleChildScrollView(
      key: const ValueKey('admin-create-user-scroll-view'),
      padding: AppSpacing.padding(context),
      child: Column(
        key: _formKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _controller.nameController,
            labelText: AppTexts.fullName,
            prefixIcon: Iconsax.user,
            onChanged: (value) {
              _controller.validateName(value);
            },
          ),
          Obx(
            () => _controller.nameError.value != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    child: AppErrorMessage(
                      message: _controller.nameError.value!,
                      icon: Iconsax.info_circle,
                      messageColor: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AppSpacing.vertical(context, 0.02),
          AppTextField(
            controller: _controller.emailController,
            labelText: AppTexts.email,
            prefixIcon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              _controller.validateEmail(value);
            },
          ),
          Obx(
            () => _controller.emailError.value != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    child: AppErrorMessage(
                      message: _controller.emailError.value!,
                      icon: Iconsax.info_circle,
                      messageColor: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AppSpacing.vertical(context, 0.02),
          AppTextField(
            controller: _controller.passwordController,
            labelText: AppTexts.password,
            prefixIcon: Iconsax.lock,
            obscureText: true,
            onChanged: (value) {
              _controller.validatePassword(value);
            },
          ),
          Obx(
            () => _controller.passwordValue.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    child: AppPasswordStrengthIndicator(
                      password: _controller.passwordValue.value,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Obx(
            () => _controller.passwordError.value != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    child: AppErrorMessage(
                      message: _controller.passwordError.value!,
                      icon: Iconsax.info_circle,
                      messageColor: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AppSpacing.vertical(context, 0.02),
          AppDropDownField<String>(
            value: _controller.roleValue.value,
            labelText: AppTexts.role,
            prefixIcon: Iconsax.user_tag,
            errorText: _controller.roleError.value,
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
                _controller.setRole(value);
              }
            },
          ),
          Obx(
            () => _controller.roleError.value != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: AppResponsive.screenHeight(context) * 0.01,
                    ),
                    child: AppErrorMessage(
                      message: _controller.roleError.value!,
                      icon: Iconsax.info_circle,
                      messageColor: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AppSpacing.vertical(context, 0.03),
          Obx(
            () => _controller.errorMessage.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: AppResponsive.screenHeight(context) * 0.02,
                    ),
                    child: AppErrorMessage(
                      message: _controller.errorMessage.value,
                      icon: Iconsax.info_circle,
                      messageColor: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Obx(
            () => AppButton(
              text: AppTexts.createUser,
              onPressed: _controller.createAdmin,
              isLoading: _controller.isLoading.value,
            ),
          ),
        ],
      ),
    );

    return AppAdminLayout(
      title: AppTexts.createNewUser,
      child: _cachedForm!,
    );
  }
}
