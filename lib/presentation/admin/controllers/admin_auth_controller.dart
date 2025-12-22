import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
// import 'package:ats/domain/repositories/auth_repository.dart';
// import 'package:ats/domain/usecases/auth/sign_up_usecase.dart';
// import 'package:ats/domain/usecases/auth/sign_in_usecase.dart';
// import 'package:ats/domain/usecases/auth/sign_out_usecase.dart';
// import 'package:ats/core/utils/app_validators/app_validators.dart';

class AdminAuthController extends GetxController {
  // final AuthRepository authRepository;

  // AdminAuthController(this.authRepository);
  AdminAuthController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Validation errors (commented out until Firebase access)
  // final emailError = Rxn<String>();
  // final passwordError = Rxn<String>();
  // final firstNameError = Rxn<String>();
  // final lastNameError = Rxn<String>();

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

  // Commented out until Firebase access
  // final signUpUseCase = SignUpUseCase(Get.find<AuthRepository>());
  // final signInUseCase = SignInUseCase(Get.find<AuthRepository>());
  // final signOutUseCase = SignOutUseCase(Get.find<AuthRepository>());

  // Validation methods (commented out until Firebase access)
  // void validateEmail(String? value) {
  //   emailError.value = AppValidators.validateEmail(value);
  // }

  // void validatePassword(String? value) {
  //   passwordError.value = AppValidators.validatePassword(value);
  // }

  // void validateFirstName(String? value) {
  //   firstNameError.value = AppValidators.validateFirstName(value);
  // }

  // void validateLastName(String? value) {
  //   lastNameError.value = AppValidators.validateLastName(value);
  // }

  // bool validateLoginForm() {
  //   validateEmail(emailController.text);
  //   validatePassword(passwordController.text);
  //   return emailError.value == null && passwordError.value == null;
  // }

  // bool validateSignUpForm() {
  //   validateFirstName(firstNameController.text);
  //   validateLastName(lastNameController.text);
  //   validateEmail(emailController.text);
  //   validatePassword(passwordController.text);
  //   return firstNameError.value == null &&
  //       lastNameError.value == null &&
  //       emailError.value == null &&
  //       passwordError.value == null;
  // }

  // Commented out until Firebase access
  // Future<void> signUp() async {
  //   if (!validateSignUpForm()) return;
  //
  //   isLoading.value = true;
  //   errorMessage.value = '';
  //
  //   final result = await signUpUseCase(
  //     email: emailController.text.trim(),
  //     password: passwordController.text,
  //     firstName: firstNameController.text.trim(),
  //     lastName: lastNameController.text.trim(),
  //   );
  //
  //   result.fold(
  //     (failure) {
  //       errorMessage.value = failure.message;
  //       isLoading.value = false;
  //     },
  //     (user) {
  //       isLoading.value = false;
  //       // Admin signup always redirects to admin dashboard
  //       if (user.role == AppConstants.roleAdmin) {
  //         Get.offAllNamed(AppConstants.routeAdminDashboard);
  //       } else {
  //         // If somehow a candidate signed up through admin route, redirect to candidate dashboard
  //         Get.offAllNamed(AppConstants.routeCandidateDashboard);
  //       }
  //     },
  //   );
  // }

  // Temporary: Direct navigation for UI development (no Firebase)
  Future<void> signIn() async {
    // Skip validation and Firebase for now - navigate directly to admin dashboard
    isLoading.value = true;
    
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    isLoading.value = false;
    Get.offAllNamed(AppConstants.routeAdminDashboard);
  }

  // Commented out until Firebase access
  // Future<void> signIn() async {
  //   if (!validateLoginForm()) return;
  //
  //   isLoading.value = true;
  //   errorMessage.value = '';
  //
  //   final result = await signInUseCase(
  //     email: emailController.text.trim(),
  //     password: passwordController.text,
  //   );
  //
  //   result.fold(
  //     (failure) {
  //       errorMessage.value = failure.message;
  //       isLoading.value = false;
  //     },
  //     (user) {
  //       isLoading.value = false;
  //       // Redirect based on role
  //       if (user.role == AppConstants.roleAdmin) {
  //         Get.offAllNamed(AppConstants.routeAdminDashboard);
  //       } else {
  //         // If candidate tries to login through admin route, redirect to candidate dashboard
  //         Get.offAllNamed(AppConstants.routeCandidateDashboard);
  //       }
  //     },
  //   );
  // }

  Future<void> signOut() async {
    // Temporary: Direct navigation (no Firebase)
    Get.offAllNamed(AppConstants.routeAdminLogin);
    
    // Commented out until Firebase access
    // isLoading.value = true;
    // final result = await signOutUseCase();
    // result.fold(
    //   (failure) {
    //     errorMessage.value = failure.message;
    //     isLoading.value = false;
    //   },
    //   (_) {
    //     isLoading.value = false;
    //     Get.offAllNamed(AppConstants.routeAdminLogin);
    //   },
    // );
  }

}

