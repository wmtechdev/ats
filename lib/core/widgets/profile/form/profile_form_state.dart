import 'package:flutter/material.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/core/widgets/profile/profile.dart';

/// Manages all form controllers and state for candidate profile
class ProfileFormState {
  final ProfileController controller;

  // Candidate Profile Controllers
  late final TextEditingController firstNameController;
  late final TextEditingController middleNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController address1Controller;
  late final TextEditingController address2Controller;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController zipController;
  late final TextEditingController ssnController;
  late final TextEditingController
  passwordController; // For candidate side (read-only, prefilled with email)

  // Phones
  final List<PhoneEntry> phoneEntries = [];

  // Specialty
  String? selectedProfession;
  final List<String> selectedSpecialties = [];

  // Background History
  String? liabilityAction;
  String? licenseAction;
  String? previouslyTraveled;
  String? terminatedFromAssignment;

  // Licensure
  String? licensureState;
  final TextEditingController npiController = TextEditingController();

  // Education
  final List<EducationEntry> educationEntries = [];

  // Certifications
  final List<CertificationEntry> certificationEntries = [];

  // Work History
  final List<WorkHistoryEntry> workHistoryEntries = [];

  ProfileFormState(this.controller) {
    _initializeControllers();
  }

  void _initializeControllers() {
    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    lastNameController = TextEditingController();

    // Get email from current user account (unchangeable)
    final currentUser = controller.authRepository.getCurrentUser();
    final userEmail = currentUser?.email ?? '';
    emailController = TextEditingController(text: userEmail);

    address1Controller = TextEditingController();
    address2Controller = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    zipController = TextEditingController();
    ssnController = TextEditingController();

    // Password field prefilled with masked placeholder (read-only for candidate)
    // Use a placeholder that represents a password, not the email
    passwordController = TextEditingController(text: '••••••••');
  }

  void loadFromProfile(dynamic profile) {
    if (profile == null) return;

    // Candidate Profile
    if (firstNameController.text.isEmpty) {
      firstNameController.text = profile.firstName ?? '';
    }
    if (middleNameController.text.isEmpty) {
      middleNameController.text = profile.middleName ?? '';
    }
    if (lastNameController.text.isEmpty) {
      lastNameController.text = profile.lastName ?? '';
    }
    // Email is always from user account, don't override it
    // Only set if empty (shouldn't happen, but just in case)
    if (emailController.text.isEmpty) {
      final currentUser = controller.authRepository.getCurrentUser();
      emailController.text = currentUser?.email ?? '';
    }
    // Password field should show masked placeholder (read-only for candidate)
    // Keep it as masked placeholder, not the email value
    if (passwordController.text.isEmpty) {
      passwordController.text = '••••••••';
    }
    if (address1Controller.text.isEmpty) {
      address1Controller.text = profile.address1 ?? '';
    }
    if (address2Controller.text.isEmpty) {
      address2Controller.text = profile.address2 ?? '';
    }
    if (cityController.text.isEmpty) {
      cityController.text = profile.city ?? '';
    }
    if (stateController.text.isEmpty) {
      stateController.text = profile.state ?? '';
    }
    if (zipController.text.isEmpty) {
      zipController.text = profile.zip ?? '';
    }
    if (ssnController.text.isEmpty) {
      ssnController.text = profile.ssn ?? '';
    }

    // Phones - Clear existing and reload from profile
    for (var phone in phoneEntries) {
      phone.countryCodeController.dispose();
      phone.numberController.dispose();
    }
    phoneEntries.clear();
    if (profile.phones != null && profile.phones!.isNotEmpty) {
      for (var phone in profile.phones) {
        phoneEntries.add(
          PhoneEntry(
            countryCodeController: TextEditingController(
              text: phone['countryCode']?.toString() ?? '+1',
            ),
            numberController: TextEditingController(
              text: phone['number']?.toString() ?? '',
            ),
          ),
        );
      }
    }

    // Specialty
    selectedProfession = profile.profession;
    // Load specialties from profile (comma-separated string to list)
    selectedSpecialties.clear();
    if (profile.specialties != null && profile.specialties!.isNotEmpty) {
      final specialtiesList = profile.specialties!
          .split(',')
          .map<String>((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList();
      selectedSpecialties.addAll(specialtiesList);
    }

    // Background History
    liabilityAction ??= profile.liabilityAction;
    licenseAction ??= profile.licenseAction;
    previouslyTraveled ??= profile.previouslyTraveled;
    terminatedFromAssignment ??= profile.terminatedFromAssignment;

    // Licensure
    licensureState = profile.licensureState;
    npiController.text = profile.npi ?? '';

    // Education - Clear existing and reload from profile
    for (var edu in educationEntries) {
      edu.institutionController.dispose();
      edu.degreeController.dispose();
      edu.fromDateController.dispose();
      edu.toDateController.dispose();
    }
    educationEntries.clear();
    if (profile.education != null && profile.education!.isNotEmpty) {
      for (var edu in profile.education) {
        educationEntries.add(
          EducationEntry(
            institutionController: TextEditingController(
              text: edu['institutionName']?.toString() ?? '',
            ),
            degreeController: TextEditingController(
              text: edu['degree']?.toString() ?? '',
            ),
            fromDateController: TextEditingController(
              text: edu['fromDate']?.toString() ?? '',
            ),
            toDateController: TextEditingController(
              text: edu['toDate']?.toString() ?? '',
            ),
            isOngoing: edu['isOngoing'] == true,
          ),
        );
      }
    }

    // Certifications - Clear existing and reload from profile
    for (var cert in certificationEntries) {
      cert.nameController.dispose();
      cert.expiryController.dispose();
    }
    certificationEntries.clear();
    if (profile.certifications != null && profile.certifications!.isNotEmpty) {
      for (var cert in profile.certifications) {
        certificationEntries.add(
          CertificationEntry(
            nameController: TextEditingController(
              text: cert['name']?.toString() ?? '',
            ),
            expiryController: TextEditingController(
              text: cert['expiry']?.toString() ?? '',
            ),
            hasNoExpiry: cert['hasNoExpiry'] == true,
          ),
        );
      }
    }

    // Work History - Clear existing and reload from profile
    for (var work in workHistoryEntries) {
      work.companyController.dispose();
      work.positionController.dispose();
      work.descriptionController.dispose();
      work.fromDateController.dispose();
      work.toDateController.dispose();
    }
    workHistoryEntries.clear();
    if (profile.workHistory != null && profile.workHistory!.isNotEmpty) {
      for (var work in profile.workHistory) {
        workHistoryEntries.add(
          WorkHistoryEntry(
            companyController: TextEditingController(
              text: work['company']?.toString() ?? '',
            ),
            positionController: TextEditingController(
              text: work['position']?.toString() ?? '',
            ),
            descriptionController: TextEditingController(
              text: work['description']?.toString() ?? '',
            ),
            fromDateController: TextEditingController(
              text: work['fromDate']?.toString() ?? '',
            ),
            toDateController: TextEditingController(
              text: work['toDate']?.toString() ?? '',
            ),
            isOngoing: work['isOngoing'] == true,
          ),
        );
      }
    }
  }

  void addPhone() {
    if (phoneEntries.length < 2) {
      phoneEntries.add(
        PhoneEntry(
          countryCodeController: TextEditingController(text: '+1'),
          numberController: TextEditingController(),
        ),
      );
    }
  }

  void removePhone(int index) {
    phoneEntries[index].countryCodeController.dispose();
    phoneEntries[index].numberController.dispose();
    phoneEntries.removeAt(index);
  }

  void addEducation() {
    educationEntries.add(
      EducationEntry(
        institutionController: TextEditingController(),
        degreeController: TextEditingController(),
        fromDateController: TextEditingController(),
        toDateController: TextEditingController(),
      ),
    );
  }

  void removeEducation(int index) {
    educationEntries[index].institutionController.dispose();
    educationEntries[index].degreeController.dispose();
    educationEntries[index].fromDateController.dispose();
    educationEntries[index].toDateController.dispose();
    educationEntries.removeAt(index);
  }

  void addCertification() {
    certificationEntries.add(
      CertificationEntry(
        nameController: TextEditingController(),
        expiryController: TextEditingController(),
      ),
    );
  }

  void removeCertification(int index) {
    certificationEntries[index].nameController.dispose();
    certificationEntries[index].expiryController.dispose();
    certificationEntries.removeAt(index);
  }

  void addWorkHistoryEntry() {
    workHistoryEntries.add(
      WorkHistoryEntry(
        companyController: TextEditingController(),
        positionController: TextEditingController(),
        descriptionController: TextEditingController(),
        fromDateController: TextEditingController(),
        toDateController: TextEditingController(),
      ),
    );
  }

  void removeWorkHistoryEntry(int index) {
    workHistoryEntries[index].companyController.dispose();
    workHistoryEntries[index].positionController.dispose();
    workHistoryEntries[index].descriptionController.dispose();
    workHistoryEntries[index].fromDateController.dispose();
    workHistoryEntries[index].toDateController.dispose();
    workHistoryEntries.removeAt(index);
    controller.clearWorkHistoryEntryErrors(index);
    final workHistory = ProfileFormDataHelper.getWorkHistoryData(
      workHistoryEntries,
    );
    controller.validateWorkHistory(workHistory.isEmpty ? null : workHistory);
  }

  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    ssnController.dispose();
    passwordController.dispose();
    // No need to dispose specialties list
    npiController.dispose();

    for (var phone in phoneEntries) {
      phone.countryCodeController.dispose();
      phone.numberController.dispose();
    }

    for (var edu in educationEntries) {
      edu.institutionController.dispose();
      edu.degreeController.dispose();
      edu.fromDateController.dispose();
      edu.toDateController.dispose();
    }

    for (var cert in certificationEntries) {
      cert.nameController.dispose();
      cert.expiryController.dispose();
    }

    for (var work in workHistoryEntries) {
      work.companyController.dispose();
      work.positionController.dispose();
      work.descriptionController.dispose();
      work.fromDateController.dispose();
      work.toDateController.dispose();
    }
  }
}
