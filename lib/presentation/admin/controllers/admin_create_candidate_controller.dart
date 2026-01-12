import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/usecases/admin/create_candidate_usecase.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCreateCandidateController extends GetxController {
  final AdminRepository adminRepository;
  late final CreateCandidateUseCase createCandidateUseCase;

  AdminCreateCandidateController(this.adminRepository) {
    createCandidateUseCase = CreateCandidateUseCase(adminRepository);
  }

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Form state
  late final AdminProfileFormState formState;

  // Observable triggers for list updates (to trigger Obx rebuilds)
  // Using counters that increment to force rebuilds even when list length doesn't change
  final phonesListTrigger = 0.obs;
  final educationListTrigger = 0.obs;
  final certificationsListTrigger = 0.obs;
  final workHistoryListTrigger = 0.obs;

  // Password field (only for creation)
  final passwordController = TextEditingController();
  final passwordError = Rxn<String>();
  final passwordValue = ''.obs;

  // Validation errors
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final emailError = Rxn<String>();
  final address1Error = Rxn<String>();
  final cityError = Rxn<String>();
  final stateError = Rxn<String>();
  final zipError = Rxn<String>();
  final professionError = Rxn<String>();
  final specialtiesError = Rxn<String>();
  final licensureStateError = Rxn<String>();
  final phonesError = Rxn<String>();
  final educationError = Rxn<String>();
  final workHistoryError = Rxn<String>();

  // Phone validation errors - Map<phoneIndex, error>
  final phoneErrors = <int, Rxn<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    formState = AdminProfileFormState();
    updateListTriggers();
  }

  void updateListTriggers() {
    // Force rebuild by always incrementing the trigger value
    // This ensures rebuilds even when list length doesn't change (e.g., checkbox updates)
    phonesListTrigger.value++;
    educationListTrigger.value++;
    certificationsListTrigger.value++;
    workHistoryListTrigger.value++;
  }

  @override
  void onClose() {
    formState.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void validateFirstName(String? value) {
    firstNameError.value = AppValidators.validateFirstName(value);
  }

  void validateLastName(String? value) {
    lastNameError.value = AppValidators.validateLastName(value);
  }

  void validateEmail(String? value) {
    emailError.value = AppValidators.validateEmail(value);
  }

  void validatePassword(String? value) {
    passwordValue.value = value ?? '';
    passwordError.value = AppValidators.validatePassword(value);
  }

  void validateAddress1(String? value) {
    address1Error.value = AppValidators.validateAddress1(value);
  }

  void validateCity(String? value) {
    cityError.value = AppValidators.validateCity(value);
  }

  void validateState(String? value) {
    stateError.value = AppValidators.validateState(value);
  }

  void validateZip(String? value) {
    zipError.value = AppValidators.validateZip(value);
  }

  void validateProfession(String? value) {
    professionError.value = AppValidators.validateProfession(value);
  }

  void validateSpecialties(String? value) {
    specialtiesError.value = AppValidators.validateSpecialties(value);
  }

  void validateLicensureState(String? value) {
    licensureStateError.value = AppValidators.validateLicensureState(value);
  }

  void validatePhoneNumber(int index, String? value) {
    if (!phoneErrors.containsKey(index)) {
      phoneErrors[index] = Rxn<String>();
    }
    phoneErrors[index]!.value = AppValidators.validatePhoneNumber(value);
    _updatePhonesGeneralError();
  }

  void _updatePhonesGeneralError() {
    bool hasErrors = false;
    for (var error in phoneErrors.values) {
      if (error.value != null) {
        hasErrors = true;
        break;
      }
    }
    if (!hasErrors) {
      phonesError.value = null;
    }
  }

  void validatePhones(List<Map<String, dynamic>>? phones) {
    phoneErrors.clear();
    if (phones == null || phones.isEmpty) {
      phonesError.value = AppTexts.phoneNumberRequired;
      return;
    }
    bool hasValidPhone = false;
    for (int i = 0; i < phones.length; i++) {
      final phone = phones[i];
      final number = phone['number']?.toString();
      final error = AppValidators.validatePhoneNumber(number);
      if (error != null) {
        phoneErrors[i] = Rxn<String>(error);
      } else {
        hasValidPhone = true;
      }
    }
    if (!hasValidPhone) {
      phonesError.value = AppTexts.phoneNumberRequired;
    } else {
      phonesError.value = null;
    }
  }

  void validateEducation(List<Map<String, dynamic>>? education) {
    if (education == null || education.isEmpty) {
      educationError.value = AppTexts.educationRequired;
      return;
    }
    educationError.value = null;
  }

  void validateWorkHistory(List<Map<String, dynamic>>? workHistory) {
    if (workHistory == null || workHistory.isEmpty) {
      workHistoryError.value = AppTexts.workHistoryRequired;
      return;
    }
    // Check that at least one entry has required fields
    bool hasValidEntry = false;
    for (var entry in workHistory) {
      final company = entry['company']?.toString().trim() ?? '';
      final position = entry['position']?.toString().trim() ?? '';
      if (company.isNotEmpty && position.isNotEmpty) {
        hasValidEntry = true;
        break;
      }
    }
    if (!hasValidEntry) {
      workHistoryError.value = AppTexts.workHistoryRequired;
    } else {
      workHistoryError.value = null;
    }
  }

  bool validateForm() {
    validateFirstName(formState.firstNameController.text);
    validateLastName(formState.lastNameController.text);
    validateEmail(formState.emailController.text);
    validatePassword(passwordController.text);
    validateAddress1(formState.address1Controller.text);
    validateCity(formState.cityController.text);
    validateState(formState.stateController.text);
    validateZip(formState.zipController.text);
    validateProfession(formState.selectedProfession);
    final specialtiesString = formState.selectedSpecialties.join(', ');
    validateSpecialties(specialtiesString);
    validateLicensureState(formState.licensureState);

    final phones =
        AdminProfileFormDataHelper.getProfileData(formState)['phones']
            as List<Map<String, dynamic>>?;
    validatePhones(phones);

    final education =
        AdminProfileFormDataHelper.getProfileData(formState)['education']
            as List<Map<String, dynamic>>?;
    validateEducation(education);

    final workHistory =
        AdminProfileFormDataHelper.getProfileData(formState)['workHistory']
            as List<Map<String, dynamic>>?;
    validateWorkHistory(workHistory);

    bool hasPhoneErrors = false;
    for (var error in phoneErrors.values) {
      if (error.value != null) {
        hasPhoneErrors = true;
        break;
      }
    }

    return firstNameError.value == null &&
        lastNameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        address1Error.value == null &&
        cityError.value == null &&
        stateError.value == null &&
        zipError.value == null &&
        professionError.value == null &&
        specialtiesError.value == null &&
        licensureStateError.value == null &&
        phonesError.value == null &&
        !hasPhoneErrors &&
        educationError.value == null &&
        workHistoryError.value == null;
  }

  Future<void> createCandidate() async {
    if (!validateForm()) {
      errorMessage.value = 'Please fix the validation errors';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final profileData = AdminProfileFormDataHelper.getProfileData(formState);

    final result = await createCandidateUseCase(
      email: formState.emailController.text.trim(),
      password: passwordController.text,
      firstName: formState.firstNameController.text.trim(),
      lastName: formState.lastNameController.text.trim(),
      middleName: profileData['middleName'] as String?,
      address1: profileData['address1'] as String?,
      address2: profileData['address2'] as String?,
      city: profileData['city'] as String?,
      state: profileData['state'] as String?,
      zip: profileData['zip'] as String?,
      ssn: profileData['ssn'] as String?,
      phones: profileData['phones'] as List<Map<String, dynamic>>?,
      profession: profileData['profession'] as String?,
      specialties: profileData['specialties'] as String?,
      liabilityAction: profileData['liabilityAction'] as String?,
      licenseAction: profileData['licenseAction'] as String?,
      previouslyTraveled: profileData['previouslyTraveled'] as String?,
      terminatedFromAssignment:
          profileData['terminatedFromAssignment'] as String?,
      licensureState: profileData['licensureState'] as String?,
      npi: profileData['npi'] as String?,
      education: profileData['education'] as List<Map<String, dynamic>>?,
      certifications:
          profileData['certifications'] as List<Map<String, dynamic>>?,
      workHistory: profileData['workHistory'] as List<Map<String, dynamic>>?,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error(failure.message);
      },
      (candidateProfile) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form
        formState.dispose();
        formState = AdminProfileFormState();
        passwordController.clear();
        firstNameError.value = null;
        lastNameError.value = null;
        emailError.value = null;
        passwordError.value = null;
        address1Error.value = null;
        cityError.value = null;
        stateError.value = null;
        zipError.value = null;
        professionError.value = null;
        specialtiesError.value = null;
        licensureStateError.value = null;
        phonesError.value = null;
        phoneErrors.clear();
        educationError.value = null;
        workHistoryError.value = null;

        AppSnackbar.success('Candidate created successfully');
        // Navigate to AdminCandidatesListScreen
        Get.offNamed(AppConstants.routeAdminCandidates);
        // Refresh the list in candidates screen
        if (Get.isRegistered<AdminCandidatesController>()) {
          final candidatesController = Get.find<AdminCandidatesController>();
          candidatesController.loadCandidates();
        }
      },
    );
  }
}
