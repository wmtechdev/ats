import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_sign_up_usecase.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_sign_in_usecase.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_sign_out_usecase.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_forgot_password_usecase.dart';
import 'package:ats/domain/usecases/candidate_auth/candidate_change_password_usecase.dart';
import 'package:ats/presentation/common/controllers/base_auth_controller.dart';
import 'package:ats/core/widgets/common/feedback/app_snackbar.dart';

/// Candidate authentication controller
/// Handles candidate-specific authentication flows with complete isolation
class CandidateAuthController extends BaseAuthController {
  final CandidateAuthRepository candidateAuthRepository;
  late final CandidateSignUpUseCase signUpUseCase;
  late final CandidateSignInUseCase signInUseCase;
  late final CandidateSignOutUseCase signOutUseCase;
  late final CandidateForgotPasswordUseCase forgotPasswordUseCase;
  late final CandidateChangePasswordUseCase changePasswordUseCase;

  // Controllers for forgot password
  TextEditingController? _forgotPasswordEmailController;
  TextEditingController get forgotPasswordEmailController {
    _forgotPasswordEmailController ??= TextEditingController();
    return _forgotPasswordEmailController!;
  }

  final forgotPasswordEmailError = Rxn<String>();
  final forgotPasswordEmailValue = ''.obs;
  final forgotPasswordSuccessMessage = ''.obs;

  // Controllers for change password
  TextEditingController? _currentPasswordController;
  TextEditingController get currentPasswordController {
    _currentPasswordController ??= TextEditingController();
    return _currentPasswordController!;
  }

  TextEditingController? _newPasswordController;
  TextEditingController get newPasswordController {
    _newPasswordController ??= TextEditingController();
    return _newPasswordController!;
  }

  TextEditingController? _confirmPasswordController;
  TextEditingController get confirmPasswordController {
    _confirmPasswordController ??= TextEditingController();
    return _confirmPasswordController!;
  }

  final currentPasswordError = Rxn<String>();
  final newPasswordError = Rxn<String>();
  final confirmPasswordError = Rxn<String>();
  final currentPasswordValue = ''.obs;
  final newPasswordValue = ''.obs;
  final confirmPasswordValue = ''.obs;
  final changePasswordSuccessMessage = ''.obs;

  CandidateAuthController(this.candidateAuthRepository) : super() {
    signUpUseCase = CandidateSignUpUseCase(candidateAuthRepository);
    signInUseCase = CandidateSignInUseCase(candidateAuthRepository);
    signOutUseCase = CandidateSignOutUseCase(candidateAuthRepository);
    forgotPasswordUseCase = CandidateForgotPasswordUseCase(
      candidateAuthRepository,
    );
    changePasswordUseCase = CandidateChangePasswordUseCase(
      candidateAuthRepository,
    );
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
  void onClose() {
    try {
      _forgotPasswordEmailController?.dispose();
      _currentPasswordController?.dispose();
      _newPasswordController?.dispose();
      _confirmPasswordController?.dispose();
      _forgotPasswordEmailController = null;
      _currentPasswordController = null;
      _newPasswordController = null;
      _confirmPasswordController = null;
    } catch (e) {
      // Controllers already disposed, ignore
    }
    super.onClose();
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
    if (emailValue.value.isEmpty ||
        emailFromController.length > emailValue.value.length) {
      if (emailValue.value != emailFromController) {
        emailValue.value = emailFromController;
      }
    }

    if (passwordValue.value.isEmpty ||
        passwordFromController.length > passwordValue.value.length) {
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

    final result = await signInUseCase(email: email, password: password);

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

  // Forgot Password Methods
  void validateForgotPasswordEmail(String? value) {
    forgotPasswordEmailValue.value = value ?? '';
    forgotPasswordEmailError.value = AppValidators.validateEmail(value);
  }

  Future<void> sendPasswordResetEmail() async {
    final email = forgotPasswordEmailValue.value.trim();

    validateForgotPasswordEmail(email);

    if (forgotPasswordEmailError.value != null) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    forgotPasswordSuccessMessage.value = '';

    final result = await forgotPasswordUseCase(email);

    result.fold(
      (failure) {
        errorMessage.value = failure.message.isNotEmpty
            ? failure.message
            : AppTexts.passwordResetFailed;
        isLoading.value = false;
        forgotPasswordSuccessMessage.value = '';
      },
      (_) {
        isLoading.value = false;
        errorMessage.value = '';
        forgotPasswordSuccessMessage.value = '';
        try {
          forgotPasswordEmailController.clear();
        } catch (e) {
          // Controller might be disposed, recreate it
          _forgotPasswordEmailController = null;
        }
        forgotPasswordEmailValue.value = '';
        forgotPasswordEmailError.value = null;
        // Show snackbar and navigate to login
        AppSnackbar.success(AppTexts.passwordResetEmailSent);
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(AppConstants.routeLogin);
        });
      },
    );
  }

  void resetForgotPasswordState() {
    try {
      forgotPasswordEmailController.clear();
    } catch (e) {
      // Controller might be disposed, recreate it
      _forgotPasswordEmailController = null;
    }
    forgotPasswordEmailValue.value = '';
    forgotPasswordEmailError.value = null;
    forgotPasswordSuccessMessage.value = '';
    errorMessage.value = '';
  }

  // Change Password Methods
  void validateCurrentPassword(String? value) {
    currentPasswordValue.value = value ?? '';
    if (value == null || value.isEmpty) {
      currentPasswordError.value = AppTexts.passwordRequired;
    } else {
      currentPasswordError.value = null;
    }

    // Re-validate new password when current password changes
    // to check if new password is same as current
    if (newPasswordValue.value.isNotEmpty) {
      validateNewPassword(newPasswordValue.value);
    }
  }

  void validateNewPassword(String? value) {
    newPasswordValue.value = value ?? '';

    // First check standard password validation
    final standardValidation = AppValidators.validatePassword(value);
    if (standardValidation != null) {
      newPasswordError.value = standardValidation;
      return;
    }

    // Check if new password is same as current password
    if (value != null &&
        value.isNotEmpty &&
        currentPasswordValue.value.isNotEmpty &&
        value == currentPasswordValue.value) {
      newPasswordError.value = AppTexts.newPasswordSameAsCurrent;
      return;
    }

    newPasswordError.value = null;
  }

  void validateConfirmPassword(String? value) {
    confirmPasswordValue.value = value ?? '';
    if (value == null || value.isEmpty) {
      confirmPasswordError.value = AppTexts.confirmPasswordRequired;
    } else if (value != newPasswordValue.value) {
      confirmPasswordError.value = AppTexts.passwordsDoNotMatch;
    } else {
      confirmPasswordError.value = null;
    }
  }

  bool validateChangePasswordForm() {
    validateCurrentPassword(currentPasswordValue.value);
    validateNewPassword(newPasswordValue.value);
    validateConfirmPassword(confirmPasswordValue.value);

    return currentPasswordError.value == null &&
        newPasswordError.value == null &&
        confirmPasswordError.value == null;
  }

  Future<void> performChangePassword() async {
    if (!validateChangePasswordForm()) {
      return;
    }

    final currentPassword = currentPasswordValue.value;
    final newPassword = newPasswordValue.value;

    isLoading.value = true;
    errorMessage.value = '';
    changePasswordSuccessMessage.value = '';

    final result = await changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) {
        // Provide more specific error messages
        if (failure.message.toLowerCase().contains('wrong password') ||
            failure.message.toLowerCase().contains('invalid') ||
            failure.message.toLowerCase().contains('credential')) {
          errorMessage.value = AppTexts.currentPasswordIncorrect;
        } else {
          errorMessage.value = failure.message.isNotEmpty
              ? failure.message
              : AppTexts.passwordChangeFailed;
        }
        isLoading.value = false;
        changePasswordSuccessMessage.value = '';
      },
      (_) {
        isLoading.value = false;
        errorMessage.value = '';
        changePasswordSuccessMessage.value = '';
        // Clear form
        try {
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        } catch (e) {
          // Controllers might be disposed, recreate them
          _currentPasswordController = null;
          _newPasswordController = null;
          _confirmPasswordController = null;
        }
        currentPasswordValue.value = '';
        newPasswordValue.value = '';
        confirmPasswordValue.value = '';
        currentPasswordError.value = null;
        newPasswordError.value = null;
        confirmPasswordError.value = null;
        // Show snackbar and navigate to profile
        AppSnackbar.success(AppTexts.passwordChanged);
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(AppConstants.routeCandidateProfile);
        });
      },
    );
  }

  void resetChangePasswordState() {
    try {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      // Controllers might be disposed, recreate them
      _currentPasswordController = null;
      _newPasswordController = null;
      _confirmPasswordController = null;
    }
    currentPasswordValue.value = '';
    newPasswordValue.value = '';
    confirmPasswordValue.value = '';
    currentPasswordError.value = null;
    newPasswordError.value = null;
    confirmPasswordError.value = null;
    changePasswordSuccessMessage.value = '';
    errorMessage.value = '';
  }
}
