import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/usecases/auth/sign_up_usecase.dart';
import 'package:ats/domain/usecases/auth/sign_in_usecase.dart';
import 'package:ats/domain/usecases/auth/sign_out_usecase.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController(this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Validation errors
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  final signUpUseCase = SignUpUseCase(Get.find<AuthRepository>());
  final signInUseCase = SignInUseCase(Get.find<AuthRepository>());
  final signOutUseCase = SignOutUseCase(Get.find<AuthRepository>());

  void validateEmail(String? value) {
    emailError.value = AppValidators.validateEmail(value);
  }

  void validatePassword(String? value) {
    passwordError.value = AppValidators.validatePassword(value);
  }

  void validateFirstName(String? value) {
    firstNameError.value = AppValidators.validateFirstName(value);
  }

  void validateLastName(String? value) {
    lastNameError.value = AppValidators.validateLastName(value);
  }

  bool validateLoginForm() {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    return emailError.value == null && passwordError.value == null;
  }

  bool validateSignUpForm() {
    validateFirstName(firstNameController.text);
    validateLastName(lastNameController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    return firstNameError.value == null &&
        lastNameError.value == null &&
        emailError.value == null &&
        passwordError.value == null;
  }

  Future<void> signUp() async {
    if (!validateSignUpForm()) return;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await signUpUseCase(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        // Redirect based on role
        if (user.role == AppConstants.roleAdmin) {
          Get.offAllNamed(AppConstants.routeAdminDashboard);
        } else {
          Get.offAllNamed(AppConstants.routeCandidateProfile);
        }
      },
    );
  }

  Future<void> signIn() async {
    if (!validateLoginForm()) return;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await signInUseCase(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        // Redirect based on role
        if (user.role == AppConstants.roleAdmin) {
          Get.offAllNamed(AppConstants.routeAdminDashboard);
        } else {
          Get.offAllNamed(AppConstants.routeCandidateDashboard);
        }
      },
    );
  }

  Future<void> signOut() async {
    isLoading.value = true;
    final result = await signOutUseCase();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        Get.offAllNamed(AppConstants.routeLogin);
      },
    );
  }

}

