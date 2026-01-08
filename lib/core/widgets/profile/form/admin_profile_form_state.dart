import 'package:flutter/material.dart';
import 'package:ats/core/widgets/profile/sections/sections.dart';
import 'package:ats/core/widgets/profile/form/profile_form_data_helper.dart';

/// Manages all form controllers and state for admin candidate profile creation/editing
class AdminProfileFormState {
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

  AdminProfileFormState() {
    _initializeControllers();
  }

  void _initializeControllers() {
    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    address1Controller = TextEditingController();
    address2Controller = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    zipController = TextEditingController();
    ssnController = TextEditingController();
  }

  void loadFromProfile(dynamic profile) {
    if (profile == null) return;

    // Candidate Profile
    firstNameController.text = profile.firstName ?? '';
    middleNameController.text = profile.middleName ?? '';
    lastNameController.text = profile.lastName ?? '';
    emailController.text = profile.email ?? '';
    address1Controller.text = profile.address1 ?? '';
    address2Controller.text = profile.address2 ?? '';
    cityController.text = profile.city ?? '';
    stateController.text = profile.state ?? '';
    zipController.text = profile.zip ?? '';
    ssnController.text = profile.ssn ?? '';

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
    liabilityAction = profile.liabilityAction;
    licenseAction = profile.licenseAction;
    previouslyTraveled = profile.previouslyTraveled;
    terminatedFromAssignment = profile.terminatedFromAssignment;

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

    for (var phone in phoneEntries) {
      phone.countryCodeController.dispose();
      phone.numberController.dispose();
    }

    npiController.dispose();

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
