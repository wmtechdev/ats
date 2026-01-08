import 'package:ats/core/widgets/profile/form/admin_profile_form_state.dart';
import 'package:ats/core/widgets/profile/form/profile_form_data_helper.dart';

/// Helper class for collecting and transforming admin form data
class AdminProfileFormDataHelper {
  static Map<String, dynamic> getProfileData(AdminProfileFormState formState) {
    final phones = ProfileFormDataHelper.getPhonesData(formState.phoneEntries);
    final education = ProfileFormDataHelper.getEducationData(
      formState.educationEntries,
    );
    final certifications = ProfileFormDataHelper.getCertificationsData(
      formState.certificationEntries,
    );
    final workHistory = ProfileFormDataHelper.getWorkHistoryData(
      formState.workHistoryEntries,
    );

    return {
      'firstName': formState.firstNameController.text.trim(),
      'lastName': formState.lastNameController.text.trim(),
      'middleName': formState.middleNameController.text.trim().isEmpty
          ? null
          : formState.middleNameController.text.trim(),
      'email': formState.emailController.text.trim().isEmpty
          ? null
          : formState.emailController.text.trim(),
      'address1': formState.address1Controller.text.trim().isEmpty
          ? null
          : formState.address1Controller.text.trim(),
      'address2': formState.address2Controller.text.trim().isEmpty
          ? null
          : formState.address2Controller.text.trim(),
      'city': formState.cityController.text.trim().isEmpty
          ? null
          : formState.cityController.text.trim(),
      'state': formState.stateController.text.trim().isEmpty
          ? null
          : formState.stateController.text.trim(),
      'zip': formState.zipController.text.trim().isEmpty
          ? null
          : formState.zipController.text.trim(),
      'ssn': formState.ssnController.text.trim().isEmpty
          ? null
          : formState.ssnController.text.trim(),
      'phones': phones.isEmpty ? null : phones,
      'profession': formState.selectedProfession,
      'specialties': formState.selectedSpecialties.isEmpty
          ? null
          : formState.selectedSpecialties.join(', '),
      'liabilityAction': formState.liabilityAction,
      'licenseAction': formState.licenseAction,
      'previouslyTraveled': formState.previouslyTraveled,
      'terminatedFromAssignment': formState.terminatedFromAssignment,
      'licensureState': formState.licensureState,
      'npi': formState.npiController.text.trim().isEmpty
          ? null
          : formState.npiController.text.trim(),
      'education': education.isEmpty ? null : education,
      'certifications': certifications.isEmpty ? null : certifications,
      'workHistory': workHistory.isEmpty ? null : workHistory,
    };
  }
}
