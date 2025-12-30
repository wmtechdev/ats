import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/usecases/admin/create_admin_usecase.dart';
import 'package:ats/presentation/admin/controllers/admin_manage_admins_controller.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCreateNewUserController extends GetxController {
  final AdminRepository adminRepository;
  late final CreateAdminUseCase createAdminUseCase;

  AdminCreateNewUserController(this.adminRepository) {
    createAdminUseCase = CreateAdminUseCase(adminRepository);
  }

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Validation errors
  final nameError = Rxn<String>();
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final roleError = Rxn<String>();

  // Current field values
  final nameValue = ''.obs;
  final emailValue = ''.obs;
  final passwordValue = ''.obs;
  final roleValue = 'recruiter'.obs; // Default to recruiter

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void validateName(String? value) {
    nameValue.value = value ?? '';
    nameError.value = AppValidators.validateFirstName(value);
  }

  void validateEmail(String? value) {
    emailValue.value = value ?? '';
    emailError.value = AppValidators.validateEmail(value);
  }

  void validatePassword(String? value) {
    passwordValue.value = value ?? '';
    passwordError.value = AppValidators.validatePassword(value);
  }

  void setRole(String role) {
    roleValue.value = role;
    roleError.value = null;
  }

  bool validateForm() {
    validateName(nameController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    
    if (roleValue.value.isEmpty) {
      roleError.value = 'Please select a role';
      return false;
    }

    return nameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        roleError.value == null;
  }

  Future<void> createAdmin() async {
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await createAdminUseCase(
      email: emailValue.value.trim(),
      password: passwordValue.value,
      name: nameValue.value.trim(),
      role: roleValue.value,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error(failure.message);
      },
      (adminProfile) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        nameValue.value = '';
        emailValue.value = '';
        passwordValue.value = '';
        roleValue.value = 'recruiter';
        nameError.value = null;
        emailError.value = null;
        passwordError.value = null;
        roleError.value = null;
        
        AppSnackbar.success('${roleValue.value == 'admin' ? 'Admin' : 'Recruiter'} created successfully');
        // Navigate to AdminManageAdminsScreen instead of going back
        // Note: The repository will sign out the newly created user to prevent auto-login
        Get.offNamed(AppConstants.routeAdminManageAdmins);
        // Refresh the list in manage admins screen
        if (Get.isRegistered<AdminManageAdminsController>()) {
          final manageController = Get.find<AdminManageAdminsController>();
          manageController.loadAdminProfiles();
        }
      },
    );
  }
}

