import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
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
  final phoneError = Rxn<String>();
  final addressError = Rxn<String>();
  final workHistoryError = Rxn<String>();
  
  // Work history validation errors - Map<entryIndex, Map<fieldName, error>>
  final workHistoryErrors = <int, Map<String, Rxn<String>>>{}.obs;

  final createProfileUseCase = CreateProfileUseCase(Get.find<CandidateProfileRepository>());

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
    _profileSubscription = profileRepository.streamProfile(currentUser.userId).listen(
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

  void validatePhone(String? value) {
    phoneError.value = AppValidators.validatePhone(value);
  }

  void validateAddress(String? value) {
    addressError.value = AppValidators.validateAddress(value);
  }

  // Validate individual work history field
  void validateWorkHistoryField(int entryIndex, String fieldName, String? value) {
    // Initialize error map for this entry if it doesn't exist
    if (!workHistoryErrors.containsKey(entryIndex)) {
      workHistoryErrors[entryIndex] = {
        'company': Rxn<String>(),
        'position': Rxn<String>(),
      };
    }

    // Validate based on field name
    if (fieldName == 'company') {
      workHistoryErrors[entryIndex]!['company']!.value = AppValidators.validateCompany(value);
    } else if (fieldName == 'position') {
      workHistoryErrors[entryIndex]!['position']!.value = AppValidators.validatePosition(value);
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
      if (entryErrors['company']?.value != null || entryErrors['position']?.value != null) {
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
      workHistoryError.value = 'Work history is required. Please add at least one work history entry.';
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
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  }) {
    validateFirstName(firstName);
    validateLastName(lastName);
    validatePhone(phone);
    validateAddress(address);
    validateWorkHistory(workHistory);

    // Check if there are any work history field errors
    bool hasWorkHistoryErrors = false;
    for (var entryErrors in workHistoryErrors.values) {
      if (entryErrors['company']?.value != null || entryErrors['position']?.value != null) {
        hasWorkHistoryErrors = true;
        break;
      }
    }

    return firstNameError.value == null &&
        lastNameError.value == null &&
        phoneError.value == null &&
        addressError.value == null &&
        workHistoryError.value == null &&
        !hasWorkHistoryErrors;
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
        currentProfile.lastName.trim().isEmpty ||
        currentProfile.phone.trim().isEmpty ||
        currentProfile.address.trim().isEmpty) {
      return false;
    }

    // Check work history - must have at least one entry with required fields
    if (currentProfile.workHistory == null || currentProfile.workHistory!.isEmpty) {
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
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  }) async {
    // Validate form
    if (!validateProfileForm(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      workHistory: workHistory,
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
    
    final result = existingProfile != null && existingProfile.profileId.isNotEmpty
        ? await profileRepository.updateProfile(
            profileId: existingProfile.profileId,
            firstName: firstName.trim(),
            lastName: lastName.trim(),
            phone: phone.trim(),
            address: address.trim(),
            workHistory: workHistory,
          )
        : await createProfileUseCase(
            userId: currentUser.userId,
            firstName: firstName.trim(),
            lastName: lastName.trim(),
            phone: phone.trim(),
            address: address.trim(),
            workHistory: workHistory,
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
            message: 'Please complete all required fields including work history',
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
    return controllers.map((entry) {
      return {
        'company': entry['company']!.text.trim(),
        'position': entry['position']!.text.trim(),
        'description': entry['description']!.text.trim(),
      };
    }).where((entry) => 
      entry['company']!.isNotEmpty || 
      entry['position']!.isNotEmpty
    ).toList();
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
        'company': TextEditingController(text: entry['company']?.toString() ?? ''),
        'position': TextEditingController(text: entry['position']?.toString() ?? ''),
        'description': TextEditingController(text: entry['description']?.toString() ?? ''),
      });
    }
  }
}

