import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/usecases/candidate_profile/create_profile_usecase.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class ProfileController extends GetxController {
  final CandidateProfileRepository profileRepository;
  final CandidateAuthRepository authRepository;

  ProfileController(this.profileRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final profile = Rxn<CandidateProfileEntity>();

  // Validation errors
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final workHistoryError = Rxn<String>();

  // New field validation errors
  final emailError = Rxn<String>();
  final address1Error = Rxn<String>();
  final cityError = Rxn<String>();
  final stateError = Rxn<String>();
  final zipError = Rxn<String>();
  final professionError = Rxn<String>();
  final specialtiesError = Rxn<String>();
  final licensureStateError = Rxn<String>();
  final educationError = Rxn<String>();
  final phonesError = Rxn<String>();

  // Phone validation errors - Map<phoneIndex, error>
  final phoneErrors = <int, Rxn<String>>{}.obs;

  // Education validation errors - Map<entryIndex, Map<fieldName, error>>
  final educationErrors = <int, Map<String, Rxn<String>>>{}.obs;

  // Work history validation errors - Map<entryIndex, Map<fieldName, error>>
  final workHistoryErrors = <int, Map<String, Rxn<String>>>{}.obs;

  final createProfileUseCase = CreateProfileUseCase(
    Get.find<CandidateProfileRepository>(),
  );

  // Stream subscription
  StreamSubscription<CandidateProfileEntity?>? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    // Cancel stream subscription to prevent permission errors after sign-out
    _profileSubscription?.cancel();
    super.onClose();
  }

  void loadProfile() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    _profileSubscription?.cancel(); // Cancel previous subscription if exists
    _profileSubscription = profileRepository
        .streamProfile(currentUser.userId)
        .listen(
          (profileData) {
            profile.value = profileData;
          },
          onError: (error) {
            // Silently handle permission errors (user might have signed out)
            // Don't show errors for permission-denied as it's expected after sign-out
          },
        );
  }

  // Validation methods
  void validateFirstName(String? value) {
    firstNameError.value = AppValidators.validateFirstName(value);
  }

  void validateLastName(String? value) {
    lastNameError.value = AppValidators.validateLastName(value);
  }

  // New validation methods
  void validateEmail(String? value) {
    emailError.value = AppValidators.validateEmail(value);
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
      phonesError.value = null; // Phones are optional
      return;
    }
    for (int i = 0; i < phones.length; i++) {
      final phone = phones[i];
      final number = phone['number']?.toString();
      validatePhoneNumber(i, number);
    }
  }

  // Validate individual education field
  void validateEducationField(int entryIndex, String fieldName, String? value) {
    // Initialize error map for this entry if it doesn't exist
    if (!educationErrors.containsKey(entryIndex)) {
      educationErrors[entryIndex] = {
        'institutionName': Rxn<String>(),
        'degree': Rxn<String>(),
      };
    }

    // Validate based on field name
    if (fieldName == 'institutionName') {
      educationErrors[entryIndex]!['institutionName']!.value =
          value == null || value.trim().isEmpty
          ? 'Institution name is required'
          : null;
    } else if (fieldName == 'degree') {
      educationErrors[entryIndex]!['degree']!.value =
          value == null || value.trim().isEmpty ? 'Degree is required' : null;
    }

    // Clear general education error if individual field errors are cleared
    _updateEducationGeneralError();
  }

  // Get error for a specific education field
  String? getEducationFieldError(int entryIndex, String fieldName) {
    if (!educationErrors.containsKey(entryIndex)) {
      return null;
    }
    return educationErrors[entryIndex]![fieldName]?.value;
  }

  // Clear errors for an education entry
  void clearEducationEntryErrors(int entryIndex) {
    educationErrors.remove(entryIndex);
    _updateEducationGeneralError();
  }

  // Update general education error based on individual field errors
  void _updateEducationGeneralError() {
    bool hasErrors = false;
    for (var entryErrors in educationErrors.values) {
      if (entryErrors['institutionName']?.value != null ||
          entryErrors['degree']?.value != null) {
        hasErrors = true;
        break;
      }
    }
    if (!hasErrors) {
      educationError.value = null;
    }
  }

  void validateEducation(List<Map<String, dynamic>>? education) {
    educationErrors.clear();
    if (education == null || education.isEmpty) {
      educationError.value = AppTexts.educationRequired;
      return;
    }
    educationError.value = null;
    // Education entries are optional fields, so no individual field validation needed
  }

  // Validate individual work history field
  void validateWorkHistoryField(
    int entryIndex,
    String fieldName,
    String? value,
  ) {
    // Initialize error map for this entry if it doesn't exist
    if (!workHistoryErrors.containsKey(entryIndex)) {
      workHistoryErrors[entryIndex] = {
        'company': Rxn<String>(),
        'position': Rxn<String>(),
      };
    }

    // Validate based on field name
    if (fieldName == 'company') {
      workHistoryErrors[entryIndex]!['company']!.value =
          AppValidators.validateCompany(value);
    } else if (fieldName == 'position') {
      workHistoryErrors[entryIndex]!['position']!.value =
          AppValidators.validatePosition(value);
    }

    // Clear general work history error if individual field errors are cleared
    _updateWorkHistoryGeneralError();
  }

  // Get error for a specific work history field
  String? getWorkHistoryFieldError(int entryIndex, String fieldName) {
    if (!workHistoryErrors.containsKey(entryIndex)) {
      return null;
    }
    return workHistoryErrors[entryIndex]![fieldName]?.value;
  }

  // Clear errors for a work history entry
  void clearWorkHistoryEntryErrors(int entryIndex) {
    workHistoryErrors.remove(entryIndex);
    _updateWorkHistoryGeneralError();
  }

  // Update general work history error based on individual field errors
  void _updateWorkHistoryGeneralError() {
    bool hasErrors = false;
    for (var entryErrors in workHistoryErrors.values) {
      if (entryErrors['company']?.value != null ||
          entryErrors['position']?.value != null) {
        hasErrors = true;
        break;
      }
    }
    if (!hasErrors) {
      workHistoryError.value = null;
    }
  }

  void validateWorkHistory(List<Map<String, dynamic>>? workHistory) {
    // Clear previous errors
    workHistoryErrors.clear();

    // Work history is required - must have at least one entry
    if (workHistory == null || workHistory.isEmpty) {
      workHistoryError.value =
          'Work history is required. Please add at least one work history entry.';
      return;
    }

    // If provided, each entry should have required fields
    for (int i = 0; i < workHistory.length; i++) {
      final entry = workHistory[i];
      // Initialize error map for this entry
      if (!workHistoryErrors.containsKey(i)) {
        workHistoryErrors[i] = {
          'company': Rxn<String>(),
          'position': Rxn<String>(),
        };
      }

      // Validate company
      workHistoryErrors[i]!['company']!.value = AppValidators.validateCompany(
        entry['company']?.toString(),
      );

      // Validate position
      workHistoryErrors[i]!['position']!.value = AppValidators.validatePosition(
        entry['position']?.toString(),
      );
    }

    _updateWorkHistoryGeneralError();
  }

  bool validateProfileForm({
    required String firstName,
    required String lastName,
    List<Map<String, dynamic>>? workHistory,
    String? email,
    String? address1,
    String? city,
    String? state,
    String? zip,
    String? profession,
    String? specialties,
    String? licensureState,
    List<Map<String, dynamic>>? phones,
    List<Map<String, dynamic>>? education,
  }) {
    validateFirstName(firstName);
    validateLastName(lastName);
    validateWorkHistory(workHistory);

    // Validate new required fields (always validate, even if empty)
    validateEmail(email);
    validateAddress1(address1);
    validateCity(city);
    validateState(state);
    validateZip(zip);
    validateProfession(profession);
    validateSpecialties(specialties);
    validateLicensureState(licensureState);
    validatePhones(phones);
    validateEducation(education);

    // Check if there are any work history field errors
    bool hasWorkHistoryErrors = false;
    for (var entryErrors in workHistoryErrors.values) {
      if (entryErrors['company']?.value != null ||
          entryErrors['position']?.value != null) {
        hasWorkHistoryErrors = true;
        break;
      }
    }

    // Check phone errors
    bool hasPhoneErrors = false;
    for (var error in phoneErrors.values) {
      if (error.value != null) {
        hasPhoneErrors = true;
        break;
      }
    }

    return firstNameError.value == null &&
        lastNameError.value == null &&
        workHistoryError.value == null &&
        !hasWorkHistoryErrors &&
        emailError.value == null &&
        address1Error.value == null &&
        cityError.value == null &&
        stateError.value == null &&
        zipError.value == null &&
        professionError.value == null &&
        specialtiesError.value == null &&
        licensureStateError.value == null &&
        educationError.value == null &&
        phonesError.value == null &&
        !hasPhoneErrors;
  }

  // Check if profile is completed
  bool isProfileCompleted() {
    final currentProfile = profile.value;

    // If profile is null, it might still be loading, so return false
    // But don't use this for redirect logic - wait for profile to load first
    if (currentProfile == null) {
      return false;
    }

    // Check basic required fields
    if (currentProfile.firstName.trim().isEmpty ||
        currentProfile.lastName.trim().isEmpty) {
      return false;
    }

    // Check new required fields
    if (currentProfile.email == null || currentProfile.email!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.address1 == null ||
        currentProfile.address1!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.city == null || currentProfile.city!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.state == null || currentProfile.state!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.zip == null || currentProfile.zip!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.profession == null ||
        currentProfile.profession!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.specialties == null ||
        currentProfile.specialties!.trim().isEmpty) {
      return false;
    }
    if (currentProfile.licensureState == null ||
        currentProfile.licensureState!.trim().isEmpty) {
      return false;
    }

    // Check phones - at least one phone required
    if (currentProfile.phones == null || currentProfile.phones!.isEmpty) {
      return false;
    }
    bool hasValidPhone = false;
    for (var phone in currentProfile.phones!) {
      final number = phone['number']?.toString().trim() ?? '';
      if (number.isNotEmpty) {
        hasValidPhone = true;
        break;
      }
    }
    if (!hasValidPhone) {
      return false;
    }

    // Check education - at least one education entry required
    if (currentProfile.education == null || currentProfile.education!.isEmpty) {
      return false;
    }

    // Check work history - must have at least one entry with required fields
    if (currentProfile.workHistory == null ||
        currentProfile.workHistory!.isEmpty) {
      return false;
    }

    // Validate that each work history entry has required fields (company and position)
    for (var entry in currentProfile.workHistory!) {
      final company = entry['company']?.toString().trim() ?? '';
      final position = entry['position']?.toString().trim() ?? '';

      // At least one entry must have both company and position filled
      if (company.isEmpty || position.isEmpty) {
        return false;
      }
    }

    return true;
  }

  Future<void> createOrUpdateProfile({
    required String firstName,
    required String lastName,
    List<Map<String, dynamic>>? workHistory,
    String? middleName,
    String? email,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zip,
    String? ssn,
    List<Map<String, dynamic>>? phones,
    String? profession,
    String? specialties,
    String? liabilityAction,
    String? licenseAction,
    String? previouslyTraveled,
    String? terminatedFromAssignment,
    String? licensureState,
    String? npi,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? certifications,
  }) async {
    // Validate form
    if (!validateProfileForm(
      firstName: firstName,
      lastName: lastName,
      workHistory: workHistory,
      email: email,
      address1: address1,
      city: city,
      state: state,
      zip: zip,
      profession: profession,
      specialties: specialties,
      licensureState: licensureState,
      phones: phones,
      education: education,
    )) {
      errorMessage.value = 'Please fix the validation errors';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) {
      errorMessage.value = 'User not authenticated';
      isLoading.value = false;
      return;
    }

    // Check if profile exists - use the stream value if available, otherwise get it
    final existingProfile = profile.value;

    final result =
        existingProfile != null && existingProfile.profileId.isNotEmpty
        ? await profileRepository.updateProfile(
            profileId: existingProfile.profileId,
            firstName: firstName.trim(),
            lastName: lastName.trim(),
            workHistory: workHistory,
            middleName: middleName?.trim(),
            email: email?.trim(),
            address1: address1?.trim(),
            address2: address2?.trim(),
            city: city?.trim(),
            state: state?.trim(),
            zip: zip?.trim(),
            ssn: ssn?.trim(),
            phones: phones,
            profession: profession?.trim(),
            specialties: specialties?.trim(),
            liabilityAction: liabilityAction?.trim(),
            licenseAction: licenseAction?.trim(),
            previouslyTraveled: previouslyTraveled?.trim(),
            terminatedFromAssignment: terminatedFromAssignment?.trim(),
            licensureState: licensureState?.trim(),
            npi: npi?.trim(),
            education: education,
            certifications: certifications,
          )
        : await profileRepository.createProfile(
            userId: currentUser.userId,
            firstName: firstName.trim(),
            lastName: lastName.trim(),
            workHistory: workHistory,
            middleName: middleName?.trim(),
            email: email?.trim(),
            address1: address1?.trim(),
            address2: address2?.trim(),
            city: city?.trim(),
            state: state?.trim(),
            zip: zip?.trim(),
            ssn: ssn?.trim(),
            phones: phones,
            profession: profession?.trim(),
            specialties: specialties?.trim(),
            liabilityAction: liabilityAction?.trim(),
            licenseAction: licenseAction?.trim(),
            previouslyTraveled: previouslyTraveled?.trim(),
            terminatedFromAssignment: terminatedFromAssignment?.trim(),
            licensureState: licensureState?.trim(),
            npi: npi?.trim(),
            education: education,
            certifications: certifications,
          );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (profileData) {
        // Update profile value - this will trigger stream update
        profile.value = profileData;
        isLoading.value = false;

        // Verify profile is complete before navigating
        if (isProfileCompleted()) {
          AppSnackbar.success('Profile saved successfully');
          // Use a small delay to ensure the profile stream has updated
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.offNamed(AppConstants.routeCandidateDashboard);
          });
        } else {
          // Profile saved but not complete - show message and stay on profile screen
          AppSnackbar.show(
            message:
                'Please complete all required fields including work history',
            duration: const Duration(seconds: 3),
          );
        }
      },
    );
  }

  // Work history management methods
  List<Map<String, dynamic>> getWorkHistoryFromControllers(
    List<Map<String, TextEditingController>> controllers,
  ) {
    return controllers
        .map((entry) {
          return {
            'company': entry['company']!.text.trim(),
            'position': entry['position']!.text.trim(),
            'description': entry['description']!.text.trim(),
          };
        })
        .where(
          (entry) =>
              entry['company']!.isNotEmpty || entry['position']!.isNotEmpty,
        )
        .toList();
  }

  void initializeWorkHistoryControllers(
    List<Map<String, dynamic>>? workHistory,
    List<Map<String, TextEditingController>> controllers,
  ) {
    if (workHistory == null || workHistory.isEmpty) {
      return;
    }

    for (var entry in workHistory) {
      controllers.add({
        'company': TextEditingController(
          text: entry['company']?.toString() ?? '',
        ),
        'position': TextEditingController(
          text: entry['position']?.toString() ?? '',
        ),
        'description': TextEditingController(
          text: entry['description']?.toString() ?? '',
        ),
      });
    }
  }
}
