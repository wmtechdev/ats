import 'package:ats/core/widgets/profile/sections/sections.dart';
import 'package:ats/core/widgets/profile/form/profile_form_state.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';

/// Helper class for collecting and transforming form data
class ProfileFormDataHelper {
  static List<Map<String, dynamic>> getPhonesData(
    List<PhoneEntry> phoneEntries,
  ) {
    return phoneEntries
        .map(
          (phone) => <String, dynamic>{
            'countryCode': phone.countryCodeController.text.trim(),
            'number': phone.numberController.text.trim(),
          },
        )
        .where((phone) => (phone['number'] as String).isNotEmpty)
        .toList();
  }

  static List<Map<String, dynamic>> getEducationData(
    List<EducationEntry> educationEntries,
  ) {
    return educationEntries
        .map(
          (edu) => <String, dynamic>{
            'institutionName': edu.institutionController.text.trim(),
            'degree': edu.degreeController.text.trim(),
            'fromDate': edu.fromDateController.text.trim(),
            'toDate': edu.toDateController.text.trim(),
            'isOngoing': edu.isOngoing,
          },
        )
        .where(
          (edu) =>
              (edu['institutionName'] as String).isNotEmpty ||
              (edu['degree'] as String).isNotEmpty,
        )
        .toList();
  }

  static List<Map<String, dynamic>> getCertificationsData(
    List<CertificationEntry> certificationEntries,
  ) {
    return certificationEntries
        .map(
          (cert) => <String, dynamic>{
            'name': cert.nameController.text.trim(),
            'expiry': cert.hasNoExpiry
                ? null
                : cert.expiryController.text.trim(),
            'hasNoExpiry': cert.hasNoExpiry,
          },
        )
        .where((cert) => (cert['name'] as String).isNotEmpty)
        .toList();
  }

  static List<Map<String, dynamic>> getWorkHistoryData(
    List<WorkHistoryEntry> workHistoryEntries,
  ) {
    return workHistoryEntries
        .map(
          (work) => <String, dynamic>{
            'company': work.companyController.text.trim(),
            'position': work.positionController.text.trim(),
            'description': work.descriptionController.text.trim(),
            'fromDate': work.fromDateController.text.trim(),
            'toDate': work.toDateController.text.trim(),
            'isOngoing': work.isOngoing,
          },
        )
        .where(
          (work) =>
              (work['company'] as String).isNotEmpty ||
              (work['position'] as String).isNotEmpty,
        )
        .toList();
  }

  static void saveProfileData(
    ProfileController controller,
    ProfileFormState formState,
  ) {
    final phones = getPhonesData(formState.phoneEntries);
    final education = getEducationData(formState.educationEntries);
    final certifications = getCertificationsData(
      formState.certificationEntries,
    );
    final workHistory = getWorkHistoryData(formState.workHistoryEntries);

    // Get email from user account (always use this, not form field)
    final currentUser = controller.authRepository.getCurrentUser();
    final userEmail = currentUser?.email ?? '';

    // Validate all fields before saving
    controller.validateFirstName(formState.firstNameController.text);
    controller.validateLastName(formState.lastNameController.text);
    controller.validateEmail(userEmail); // Validate using account email
    controller.validateAddress1(formState.address1Controller.text);
    controller.validateCity(formState.cityController.text);
    controller.validateState(formState.stateController.text);
    controller.validateZip(formState.zipController.text);
    controller.validateProfession(formState.selectedProfession);
    // Validate specialties as comma-separated string
    final specialtiesString = formState.selectedSpecialties.join(', ');
    controller.validateSpecialties(specialtiesString);
    controller.validateLicensureState(formState.licensureState);
    controller.validatePhones(phones.isEmpty ? null : phones);
    controller.validateEducation(education.isEmpty ? null : education);
    controller.validateWorkHistory(workHistory.isEmpty ? null : workHistory);

    controller.createOrUpdateProfile(
      firstName: formState.firstNameController.text,
      lastName: formState.lastNameController.text,
      workHistory: workHistory.isEmpty ? null : workHistory,
      middleName: formState.middleNameController.text.trim().isEmpty
          ? null
          : formState.middleNameController.text.trim(),
      email: userEmail.isNotEmpty
          ? userEmail
          : null, // Always use account email
      address1: formState.address1Controller.text.trim().isEmpty
          ? null
          : formState.address1Controller.text.trim(),
      address2: formState.address2Controller.text.trim().isEmpty
          ? null
          : formState.address2Controller.text.trim(),
      city: formState.cityController.text.trim().isEmpty
          ? null
          : formState.cityController.text.trim(),
      state: formState.stateController.text.trim().isEmpty
          ? null
          : formState.stateController.text.trim(),
      zip: formState.zipController.text.trim().isEmpty
          ? null
          : formState.zipController.text.trim(),
      ssn: formState.ssnController.text.trim().isEmpty
          ? null
          : formState.ssnController.text.trim(),
      phones: phones.isEmpty ? null : phones,
      profession: formState.selectedProfession,
      specialties: formState.selectedSpecialties.isEmpty
          ? null
          : formState.selectedSpecialties.join(', '),
      liabilityAction: formState.liabilityAction,
      licenseAction: formState.licenseAction,
      previouslyTraveled: formState.previouslyTraveled,
      terminatedFromAssignment: formState.terminatedFromAssignment,
      licensureState: formState.licensureState,
      npi: formState.npiController.text.trim().isEmpty
          ? null
          : formState.npiController.text.trim(),
      education: education.isEmpty ? null : education,
      certifications: certifications.isEmpty ? null : certifications,
    );
  }
}
