import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/domain/entities/user_entity.dart';

/// Base authentication controller with shared functionality
/// This controller handles common auth operations that are used by both
/// admin and candidate authentication flows
/// 
/// Generic type T represents the specific repository type (AdminAuthRepository or CandidateAuthRepository)
abstract class BaseAuthController extends GetxController {

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Validation errors
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final phoneError = Rxn<String>();
  final addressError = Rxn<String>();

  // Current field values - updated in real-time as user types
  // This ensures we always have the latest values regardless of controller sync issues
  final emailValue = ''.obs;
  final passwordValue = ''.obs;
  final firstNameValue = ''.obs;
  final lastNameValue = ''.obs;
  final phoneValue = ''.obs;
  final addressValue = ''.obs;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Abstract methods for use cases - must be implemented by child classes
  Future<void> performSignUp();
  Future<void> performSignIn();
  Future<void> performSignOut();

  @override
  void onInit() {
    super.onInit();
    // Clear all validation errors when controller is initialized
    // This ensures clean state when navigating to login screen
    _clearValidationErrors();
  }

  @override
  void onClose() {
    try {
      emailController.dispose();
      passwordController.dispose();
      firstNameController.dispose();
      lastNameController.dispose();
      phoneController.dispose();
      addressController.dispose();
    } catch (e) {
      // Controllers already disposed, ignore
    }
    super.onClose();
  }

  void clearControllers() {
    try {
      emailController.clear();
      passwordController.clear();
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      addressController.clear();
    } catch (e) {
      // Controllers might already be disposed, ignore
    }
  }

  void resetState() {
    // Clear all validation errors
    _clearValidationErrors();
    // Clear stored values
    emailValue.value = '';
    passwordValue.value = '';
    firstNameValue.value = '';
    lastNameValue.value = '';
    phoneValue.value = '';
    addressValue.value = '';
    // Clear error message
    errorMessage.value = '';
    // Clear loading state
    isLoading.value = false;
    // Note: Don't clear text controllers here as user might want to keep their input
  }

  void _clearValidationErrors() {
    emailError.value = null;
    passwordError.value = null;
    firstNameError.value = null;
    lastNameError.value = null;
    phoneError.value = null;
    addressError.value = null;
  }

  // Validation methods
  void validateEmail(String? value) {
    // Update stored value
    emailValue.value = value ?? '';
    // Validate
    emailError.value = AppValidators.validateEmail(value);
  }

  void validatePassword(String? value) {
    // Update stored value
    passwordValue.value = value ?? '';
    // Validate
    passwordError.value = AppValidators.validatePassword(value);
  }

  void validateFirstName(String? value) {
    // Update stored value
    firstNameValue.value = value ?? '';
    // Validate
    firstNameError.value = AppValidators.validateFirstName(value);
  }

  void validateLastName(String? value) {
    // Update stored value
    lastNameValue.value = value ?? '';
    // Validate
    lastNameError.value = AppValidators.validateLastName(value);
  }

  void validatePhone(String? value) {
    // Update stored value
    phoneValue.value = value ?? '';
    // Validate - phone is optional but if provided should be valid
    if (value != null && value.trim().isNotEmpty) {
      // Basic phone validation (can be enhanced)
      if (value.trim().length < 10) {
        phoneError.value = 'Phone number must be at least 10 digits';
      } else {
        phoneError.value = null;
      }
    } else {
      phoneError.value = null; // Optional field
    }
  }

  void validateAddress(String? value) {
    // Update stored value
    addressValue.value = value ?? '';
    // Validate - address is optional but if provided should be valid
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 5) {
        addressError.value = 'Address must be at least 5 characters';
      } else {
        addressError.value = null;
      }
    } else {
      addressError.value = null; // Optional field
    }
  }

  bool validateLoginForm() {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    return emailError.value == null && passwordError.value == null;
  }

  bool validateSignUpForm() {
    // Sync stored values with controller values as fallback
    // This ensures we have the latest values even if onChanged wasn't called
    if (firstNameValue.value != firstNameController.text) {
      firstNameValue.value = firstNameController.text;
    }
    if (lastNameValue.value != lastNameController.text) {
      lastNameValue.value = lastNameController.text;
    }
    if (emailValue.value != emailController.text) {
      emailValue.value = emailController.text;
    }
    if (passwordValue.value != passwordController.text) {
      passwordValue.value = passwordController.text;
    }
    if (phoneValue.value != phoneController.text) {
      phoneValue.value = phoneController.text;
    }
    if (addressValue.value != addressController.text) {
      addressValue.value = addressController.text;
    }
    
    // Use stored values (updated in real-time via onChanged callbacks)
    // This is more reliable than reading from controllers which may have sync issues
    validateFirstName(firstNameValue.value);
    validateLastName(lastNameValue.value);
    validateEmail(emailValue.value);
    validatePassword(passwordValue.value);
    // Phone and address validation only for candidate (optional)
    if (signUpRole == AppConstants.roleCandidate) {
      validatePhone(phoneValue.value);
      validateAddress(addressValue.value);
    }
    return firstNameError.value == null &&
        lastNameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        phoneError.value == null &&
        addressError.value == null;
  }

  // Abstract methods that must be implemented by child classes
  /// Get the role for sign-up (admin or candidate)
  String get signUpRole;

  /// Handle navigation after successful sign-up
  void handleSignUpSuccess(UserEntity user);

  /// Handle navigation after successful sign-in
  void handleSignInSuccess(UserEntity user);

  /// Get the route to navigate to after sign-out
  String get signOutRoute;

  /// Get the controller type name for deletion
  String get controllerTypeName;

  /// Get phone and address for candidate signup (returns empty for admin)
  /// Override in candidate controller to return actual values
  String get phoneForSignUp => phoneValue.value.trim();
  String get addressForSignUp => addressValue.value.trim();

  // Sign up method - delegates to child class implementation
  Future<void> signUp() async {
    if (!validateSignUpForm()) return;
    await performSignUp();
  }

  // Sign in method - delegates to child class implementation
  Future<void> signIn() async {
    // Use stored values (updated in real-time via onChanged callbacks)
    // This is more reliable than reading from controllers which may have sync issues
    final email = emailValue.value.trim();
    final password = passwordValue.value;
    
    // Validate form with current values
    // This will set error messages if validation fails
    validateEmail(email);
    validatePassword(password);
    
    // Check if validation passed
    // If either field has an error, stop here and show the errors
    if (emailError.value != null || passwordError.value != null) {
      // Validation failed, don't proceed
      // The errors are already set by validateEmail/validatePassword above
      return;
    }

    await performSignIn();
  }

  // Sign out method - delegates to child class implementation
  Future<void> signOut() async {
    await performSignOut();
  }

  /// Delete the controller instance
  /// Must be implemented by child classes to delete the correct type
  void deleteController();
}

