import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_validators/app_validators.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminEditCandidateScreen extends StatefulWidget {
  const AdminEditCandidateScreen({super.key});

  @override
  State<AdminEditCandidateScreen> createState() =>
      _AdminEditCandidateScreenState();
}

class _AdminEditCandidateScreenState extends State<AdminEditCandidateScreen> {
  final controller = Get.find<AdminCandidatesController>();
  late final AdminProfileFormState formState;
  Widget? _cachedForm;
  final _formKey = GlobalKey(debugLabel: 'admin-edit-candidate-form');

  // Password field (for admin side only)
  final passwordController = TextEditingController();
  final passwordError = Rxn<String>();

  // Validation errors
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
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

  // Phone validation errors
  final phoneErrors = <int, Rxn<String>>{}.obs;

  @override
  void initState() {
    super.initState();
    formState = AdminProfileFormState();

    // Set password field to masked placeholder (read-only in edit mode)
    passwordController.text = '••••••••';

    // Load existing profile data when it becomes available
    ever(controller.selectedCandidateProfile, (profile) {
      if (profile != null && mounted) {
        formState.loadFromProfile(profile);
        setState(() {});
      }
    });

    // Load initial profile if already available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedCandidateProfile.value != null && mounted) {
        formState.loadFromProfile(controller.selectedCandidateProfile.value);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    formState.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final profileData = AdminProfileFormDataHelper.getProfileData(formState);

    controller.updateCandidateProfile(
      firstName: formState.firstNameController.text.trim(),
      lastName: formState.lastNameController.text.trim(),
      middleName: profileData['middleName'] as String?,
      email: formState.emailController.text.trim().isEmpty
          ? null
          : formState.emailController.text.trim(),
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
  }

  @override
  Widget build(BuildContext context) {
    _cachedForm ??= Builder(
      builder: (context) => Obx(() {
        final candidate = controller.selectedCandidate.value;
        if (candidate == null) {
          return AppEmptyState(
            message: AppTexts.candidateNotFound,
            icon: Iconsax.profile_circle,
          );
        }

        return SingleChildScrollView(
          key: const ValueKey('admin-edit-candidate-scroll-view'),
          padding: AppSpacing.padding(context),
          child: Column(
            key: _formKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Candidate Profile Section
              CandidateProfileSection(
                firstNameController: formState.firstNameController,
                middleNameController: formState.middleNameController,
                lastNameController: formState.lastNameController,
                emailController: formState.emailController,
                passwordController: passwordController,
                emailEnabled: false, // Email is disabled in admin edit
                passwordEnabled: false, // Password is disabled in admin edit
                address1Controller: formState.address1Controller,
                address2Controller: formState.address2Controller,
                cityController: formState.cityController,
                stateController: formState.stateController,
                zipController: formState.zipController,
                ssnController: formState.ssnController,
                firstNameError: firstNameError,
                lastNameError: lastNameError,
                emailError: Rxn<String>(),
                passwordError: passwordError,
                address1Error: address1Error,
                cityError: cityError,
                stateError: stateError,
                zipError: zipError,
                onFirstNameChanged: (_) => null,
                onLastNameChanged: (_) => null,
                onEmailChanged: (_) => null,
                onPasswordChanged: (value) {
                  passwordError.value = AppValidators.validatePassword(value);
                  return null;
                },
                onAddress1Changed: (_) => null,
                onCityChanged: (_) => null,
                onStateChanged: (_) => null,
                onZipChanged: (_) => null,
                hasError: false, // Individual error messages are already wrapped in Obx
              ),
              AppSpacing.vertical(context, 0.02),

              // Phones Section
              Obx(
                () => PhonesSection(
                  phoneEntries: formState.phoneEntries.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final phone = entry.value;
                    return PhoneEntry(
                      countryCodeController: phone.countryCodeController,
                      numberController: phone.numberController,
                      numberError: phoneErrors[index] ?? Rxn<String>(null),
                    );
                  }).toList(),
                  onCountryCodeChanged: (index, countryCode) {},
                  onNumberChanged: (index, number) {},
                  onAddPhone: () {
                    setState(() {
                      formState.addPhone();
                    });
                  },
                  onRemovePhone: (index) {
                    setState(() {
                      formState.removePhone(index);
                    });
                  },
                  hasError:
                      phonesError.value != null ||
                      phoneErrors.values.any((e) => e.value != null),
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Specialty Section
              Obx(
                () => SpecialtySection(
                  selectedProfession: formState.selectedProfession,
                  selectedSpecialties: formState.selectedSpecialties,
                  professionError: professionError,
                  specialtiesError: specialtiesError,
                  onProfessionChanged: (value) {
                    setState(() {
                      formState.selectedProfession = value;
                    });
                  },
                  onSpecialtiesChanged: (specialties) {
                    setState(() {
                      formState.selectedSpecialties.clear();
                      formState.selectedSpecialties.addAll(specialties);
                    });
                  },
                  hasError:
                      professionError.value != null ||
                      specialtiesError.value != null,
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Background History Section
              BackgroundHistorySection(
                liabilityAction: formState.liabilityAction,
                licenseAction: formState.licenseAction,
                previouslyTraveled: formState.previouslyTraveled,
                terminatedFromAssignment: formState.terminatedFromAssignment,
                onLiabilityActionChanged: (value) {
                  setState(() {
                    formState.liabilityAction = value;
                  });
                },
                onLicenseActionChanged: (value) {
                  setState(() {
                    formState.licenseAction = value;
                  });
                },
                onPreviouslyTraveledChanged: (value) {
                  setState(() {
                    formState.previouslyTraveled = value;
                  });
                },
                onTerminatedFromAssignmentChanged: (value) {
                  setState(() {
                    formState.terminatedFromAssignment = value;
                  });
                },
              ),
              AppSpacing.vertical(context, 0.02),

              // Licensure Section
              Obx(
                () => LicensureSection(
                  selectedState: formState.licensureState,
                  npiController: formState.npiController,
                  onStateChanged: (value) {
                    setState(() {
                      formState.licensureState = value;
                    });
                  },
                  stateError: licensureStateError,
                  hasError: licensureStateError.value != null,
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Education Section
              Obx(
                () => EducationSection(
                  educationEntries: formState.educationEntries,
                  onOngoingChanged: (index, isOngoing) {
                    setState(() {
                      formState.educationEntries[index] = EducationEntry(
                        institutionController: formState
                            .educationEntries[index]
                            .institutionController,
                        degreeController:
                            formState.educationEntries[index].degreeController,
                        fromDateController: formState
                            .educationEntries[index]
                            .fromDateController,
                        toDateController:
                            formState.educationEntries[index].toDateController,
                        isOngoing: isOngoing,
                      );
                    });
                  },
                  onInstitutionChanged: (index, institution) {},
                  onDegreeChanged: (index, degree) {},
                  onFromDateChanged: (index, fromDate) {},
                  onToDateChanged: (index, toDate) {},
                  onAddEducation: () {
                    setState(() {
                      formState.addEducation();
                    });
                  },
                  onRemoveEducation: (index) {
                    setState(() {
                      formState.removeEducation(index);
                    });
                  },
                  generalError: educationError,
                  hasError: educationError.value != null,
                ),
              ),
              AppSpacing.vertical(context, 0.02),

              // Certifications Section
              CertificationsSection(
                certificationEntries: formState.certificationEntries,
                onNoExpiryChanged: (index, hasNoExpiry) {
                  setState(() {
                    formState.certificationEntries[index] = CertificationEntry(
                      nameController:
                          formState.certificationEntries[index].nameController,
                      expiryController: formState
                          .certificationEntries[index]
                          .expiryController,
                      hasNoExpiry: hasNoExpiry,
                    );
                  });
                },
                onAddCertification: () {
                  setState(() {
                    formState.addCertification();
                  });
                },
                onRemoveCertification: (index) {
                  setState(() {
                    formState.removeCertification(index);
                  });
                },
              ),
              AppSpacing.vertical(context, 0.02),

              // Work History Section
              Obx(
                () => WorkHistorySectionWidget(
                  workHistoryEntries: formState.workHistoryEntries,
                  onOngoingChanged: (index, isOngoing) {
                    setState(() {
                      formState.workHistoryEntries[index] = WorkHistoryEntry(
                        companyController: formState
                            .workHistoryEntries[index]
                            .companyController,
                        positionController: formState
                            .workHistoryEntries[index]
                            .positionController,
                        descriptionController: formState
                            .workHistoryEntries[index]
                            .descriptionController,
                        fromDateController: formState
                            .workHistoryEntries[index]
                            .fromDateController,
                        toDateController: formState
                            .workHistoryEntries[index]
                            .toDateController,
                        isOngoing: isOngoing,
                      );
                    });
                  },
                  onCompanyChanged: (index, company) {},
                  onPositionChanged: (index, position) {},
                  onFromDateChanged: (index, fromDate) {},
                  onToDateChanged: (index, toDate) {},
                  onAdd: () {
                    setState(() {
                      formState.addWorkHistoryEntry();
                    });
                  },
                  onRemove: (index) {
                    setState(() {
                      formState.removeWorkHistoryEntry(index);
                    });
                  },
                  generalError: workHistoryError,
                  hasError: workHistoryError.value != null,
                ),
              ),
              AppSpacing.vertical(context, 0.03),

              // Error Message
              Obx(
                () => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: AppSpacing.vertical(context, 0.02).height!,
                        ),
                        child: AppErrorMessage(
                          message: controller.errorMessage.value,
                          icon: Iconsax.info_circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Save Button
              Obx(
                () => AppButton(
                  text: AppTexts.update,
                  onPressed: _saveProfile,
                  isLoading: controller.isLoading.value,
                ),
              ),
            ],
          ),
        );
      }),
    );

    return AppAdminLayout(
      title: '${AppTexts.edit} ${AppTexts.candidate}',
      child: _cachedForm!,
    );
  }
}
