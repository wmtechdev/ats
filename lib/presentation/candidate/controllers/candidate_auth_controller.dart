import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_sign_up_usecase.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_sign_in_usecase.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_sign_out_usecase.dart';
import 'package:ats/presentation/common/controllers/base_auth_controller.dart';

/// Candidate authentication controller
/// Handles candidate-specific authentication flows with complete isolation
class CandidateAuthController extends BaseAuthController {
  final CandidateAuthRepository candidateAuthRepository;
  late final CandidateSignUpUseCase signUpUseCase;
  late final CandidateSignInUseCase signInUseCase;
  late final CandidateSignOutUseCase signOutUseCase;

  CandidateAuthController(this.candidateAuthRepository) : super() {
    signUpUseCase = CandidateSignUpUseCase(candidateAuthRepository);
    signInUseCase = CandidateSignInUseCase(candidateAuthRepository);
    signOutUseCase = CandidateSignOutUseCase(candidateAuthRepository);
  }

  @override
  String get signUpRole => AppConstants.roleCandidate;

  @override
  void handleSignUpSuccess(UserEntity user) {
    // Candidate signup redirects to dashboard
    Get.offAllNamed(AppConstants.routeCandidateDashboard);
  }

  @override
  void handleSignInSuccess(UserEntity user) {
    // Candidate login redirects to dashboard
    // Role validation is handled at repository level
    Get.offAllNamed(AppConstants.routeCandidateDashboard);
  }

  @override
  String get signOutRoute => AppConstants.routeLogin;

  @override
  String get controllerTypeName => 'CandidateAuthController';

  @override
  void deleteController() {
    Get.delete<CandidateAuthController>();
  }

  @override
  Future<void> performSignUp() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await signUpUseCase(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneForSignUp,
      address: addressForSignUp,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form fields after successful signup
        clearControllers();
        // Clear all validation errors
        firstNameError.value = null;
        lastNameError.value = null;
        emailError.value = null;
        passwordError.value = null;
        phoneError.value = null;
        addressError.value = null;
        // Clear stored values
        firstNameValue.value = '';
        lastNameValue.value = '';
        emailValue.value = '';
        passwordValue.value = '';
        phoneValue.value = '';
        addressValue.value = '';
        // Handle navigation
        handleSignUpSuccess(user);
      },
    );
  }

  @override
  Future<void> performSignIn() async {
    final email = emailValue.value.trim();
    final password = passwordValue.value;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form fields after successful login
        clearControllers();
        // Clear all validation errors
        emailError.value = null;
        passwordError.value = null;
        // Clear stored values
        emailValue.value = '';
        passwordValue.value = '';
        // Handle navigation
        handleSignInSuccess(user);
      },
    );
  }

  @override
  Future<void> performSignOut() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await signOutUseCase();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear all validation errors and stored values
        resetState();
        // Clear controllers before navigation
        clearControllers();

        // Delete this controller to force fresh recreation
        try {
          Get.delete<CandidateAuthController>();
        } catch (e) {
          // Controller might already be deleted, ignore
        }

        // Use post-frame callback to ensure current widget build cycle completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(signOutRoute);
        });
      },
    );
  }
}
