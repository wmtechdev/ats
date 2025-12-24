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
    // Candidate signup redirects to profile screen to complete profile
    Get.offAllNamed(AppConstants.routeCandidateProfile);
  }

  @override
  void handleSignInSuccess(UserEntity user) {
    // Candidate login redirects based on profile completion
    // Profile completion check will be handled by middleware
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
  bool validateSignUpForm() {
    // For candidate signup, only validate email and password
    // Stored values are updated in real-time via onChanged callbacks, so they're the source of truth
    // Only sync from controller if stored values are empty or controller has more complete data
    
    final emailFromController = emailController.text.trim();
    final passwordFromController = passwordController.text;
    
    // Only sync if stored value is empty or controller value is longer (more complete)
    // This prevents overwriting correct stored values with stale controller values
    if (emailValue.value.isEmpty || emailFromController.length > emailValue.value.length) {
      if (emailValue.value != emailFromController) {
        emailValue.value = emailFromController;
      }
    }
    
    if (passwordValue.value.isEmpty || passwordFromController.length > passwordValue.value.length) {
      if (passwordValue.value != passwordFromController) {
        passwordValue.value = passwordFromController;
      }
    }
    
    // Use stored values (updated in real-time via onChanged callbacks)
    // This is more reliable than reading from controllers which may have sync issues
    // The validation methods will update error observables correctly
    validateEmail(emailValue.value);
    validatePassword(passwordValue.value);
    
    // Return true only if both validations pass (no errors)
    return emailError.value == null && passwordError.value == null;
  }

  @override
  Future<void> performSignUp() async {
    isLoading.value = true;
    errorMessage.value = '';

    // Use stored values (the ones that were validated) instead of controller values
    // Controller values may be stale due to sync issues with the text field
    final email = emailValue.value.trim();
    final password = passwordValue.value;

    // For candidate signup, only email and password are required
    // Profile will be completed in the profile screen
    final result = await signUpUseCase(
      email: email,
      password: password,
      firstName: '', // Will be filled in profile screen
      lastName: '', // Will be filled in profile screen
      phone: null, // Will be filled in profile screen
      address: null, // Will be filled in profile screen
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
        emailError.value = null;
        passwordError.value = null;
        // Clear stored values
        emailValue.value = '';
        passwordValue.value = '';
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
