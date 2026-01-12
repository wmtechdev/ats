import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';

class CandidateProfileSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipController;
  final TextEditingController ssnController;
  final TextEditingController?
  passwordController; // Optional, for admin side or candidate side
  final bool emailEnabled; // Controls if email field is editable
  final bool passwordEnabled; // Controls if password field is editable
  final String? Function(String?)? onFirstNameChanged;
  final String? Function(String?)? onLastNameChanged;
  final String? Function(String?)? onEmailChanged;
  final String? Function(String?)?
  onPasswordChanged; // Optional, for admin side or candidate side
  final String? Function(String?)? onAddress1Changed;
  final String? Function(String?)? onCityChanged;
  final String? Function(String?)? onStateChanged;
  final String? Function(String?)? onZipChanged;
  final Rxn<String>? firstNameError;
  final Rxn<String>? lastNameError;
  final Rxn<String>? emailError;
  final Rxn<String>? passwordError; // Optional, for admin side only
  final String? passwordValue; // Optional, for password strength indicator
  final Rxn<String>? address1Error;
  final Rxn<String>? cityError;
  final Rxn<String>? stateError;
  final Rxn<String>? zipError;
  final bool hasError;

  const CandidateProfileSection({
    super.key,
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.emailController,
    required this.address1Controller,
    required this.address2Controller,
    required this.cityController,
    required this.stateController,
    required this.zipController,
    required this.ssnController,
    this.passwordController,
    this.emailEnabled = false, // Default to disabled (read-only)
    this.passwordEnabled = false, // Default to disabled (read-only)
    this.onFirstNameChanged,
    this.onLastNameChanged,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.onAddress1Changed,
    this.onCityChanged,
    this.onStateChanged,
    this.onZipChanged,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.passwordValue,
    this.address1Error,
    this.cityError,
    this.stateError,
    this.zipError,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      title: AppTexts.candidateProfile,
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Name
          AppTextField(
            controller: firstNameController,
            labelText: '${AppTexts.firstName}(*)',
            showLabelAbove: true,
            onChanged: onFirstNameChanged,
          ),
          if (firstNameError != null)
            Obx(
              () => firstNameError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: firstNameError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // Middle Name
          AppTextField(
            controller: middleNameController,
            labelText: AppTexts.middleName,
            showLabelAbove: true,
          ),
          AppSpacing.vertical(context, 0.02),

          // Last Name
          AppTextField(
            controller: lastNameController,
            labelText: '${AppTexts.lastName}(*)',
            showLabelAbove: true,
            onChanged: onLastNameChanged,
          ),
          if (lastNameError != null)
            Obx(
              () => lastNameError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: lastNameError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // Email
          AppTextField(
            controller: emailController,
            labelText: '${AppTexts.email}(*)',
            showLabelAbove: true,
            keyboardType: TextInputType.emailAddress,
            enabled: emailEnabled, // Controlled by parameter
            onChanged: onEmailChanged,
          ),
          if (emailError != null)
            Obx(
              () => emailError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: emailError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // Password (admin side or candidate side)
          if (passwordController != null) ...[
            AppTextField(
              controller: passwordController!,
              labelText: '${AppTexts.password}(*)',
              showLabelAbove: true,
              obscureText: true, // Always obscured, even when read-only
              enabled: passwordEnabled, // Controlled by parameter
              onChanged: onPasswordChanged,
            ),
            if (passwordValue != null &&
                passwordValue!.isNotEmpty &&
                passwordEnabled)
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.vertical(context, 0.01).height!,
                ),
                child: AppPasswordStrengthIndicator(password: passwordValue),
              ),
            if (passwordError != null)
              Obx(
                () => passwordError!.value != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: AppSpacing.vertical(context, 0.01).height!,
                        ),
                        child: AppErrorMessage(
                          message: passwordError!.value!,
                          icon: Iconsax.info_circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            AppSpacing.vertical(context, 0.02),
          ],

          // Address 1
          AppTextField(
            controller: address1Controller,
            labelText: '${AppTexts.address1}(*)',
            showLabelAbove: true,
            onChanged: onAddress1Changed,
          ),
          if (address1Error != null)
            Obx(
              () => address1Error!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: address1Error!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // Address 2
          AppTextField(
            controller: address2Controller,
            labelText: AppTexts.address2,
            showLabelAbove: true,
          ),
          AppSpacing.vertical(context, 0.02),

          // City
          AppTextField(
            controller: cityController,
            labelText: '${AppTexts.city}(*)',
            showLabelAbove: true,
            onChanged: onCityChanged,
          ),
          if (cityError != null)
            Obx(
              () => cityError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: cityError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // State
          AppTextField(
            controller: stateController,
            labelText: '${AppTexts.state}(*)',
            showLabelAbove: true,
            onChanged: onStateChanged,
          ),
          if (stateError != null)
            Obx(
              () => stateError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: stateError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // Zip
          AppTextField(
            controller: zipController,
            labelText: '${AppTexts.zip}(*)',
            showLabelAbove: true,
            keyboardType: TextInputType.number,
            onChanged: onZipChanged,
          ),
          if (zipError != null)
            Obx(
              () => zipError!.value != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.vertical(context, 0.01).height!,
                      ),
                      child: AppErrorMessage(
                        message: zipError!.value!,
                        icon: Iconsax.info_circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          AppSpacing.vertical(context, 0.02),

          // SSN
          AppTextField(
            controller: ssnController,
            labelText: AppTexts.ssn,
            showLabelAbove: true,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
