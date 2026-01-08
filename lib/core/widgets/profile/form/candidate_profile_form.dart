import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateProfileForm extends StatefulWidget {
  const CandidateProfileForm({super.key});

  @override
  State<CandidateProfileForm> createState() => _CandidateProfileFormState();
}

class _CandidateProfileFormState extends State<CandidateProfileForm> {
  final controller = Get.find<ProfileController>();
  late final ProfileFormState formState;

  @override
  void initState() {
    super.initState();
    formState = ProfileFormState(controller);
    _loadProfileData();
  }

  void _loadProfileData() {
    ever(controller.profile, (profile) {
      if (profile != null && mounted) {
        formState.loadFromProfile(profile);
        if (mounted) setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.profile.value != null && mounted) {
        formState.loadFromProfile(controller.profile.value!);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    formState.dispose();
    super.dispose();
  }

  bool _hasPhonesErrors() {
    for (var error in controller.phoneErrors.values) {
      if (error.value != null) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Candidate Profile Section
        Obx(
          () => CandidateProfileSection(
            firstNameController: formState.firstNameController,
            middleNameController: formState.middleNameController,
            lastNameController: formState.lastNameController,
            emailController: formState.emailController,
            passwordController: formState.passwordController,
            emailEnabled: false, // Email is read-only for candidates
            passwordEnabled:
                false, // Password is read-only for candidates (prefilled with email)
            address1Controller: formState.address1Controller,
            address2Controller: formState.address2Controller,
            cityController: formState.cityController,
            stateController: formState.stateController,
            zipController: formState.zipController,
            ssnController: formState.ssnController,
            onFirstNameChanged: (value) {
              controller.validateFirstName(value);
              return null;
            },
            onLastNameChanged: (value) {
              controller.validateLastName(value);
              return null;
            },
            onEmailChanged: (value) {
              controller.validateEmail(value);
              return null;
            },
            onAddress1Changed: (value) {
              controller.validateAddress1(value);
              return null;
            },
            onCityChanged: (value) {
              controller.validateCity(value);
              return null;
            },
            onStateChanged: (value) {
              controller.validateState(value);
              return null;
            },
            onZipChanged: (value) {
              controller.validateZip(value);
              return null;
            },
            firstNameError: controller.firstNameError,
            lastNameError: controller.lastNameError,
            emailError: controller.emailError,
            address1Error: controller.address1Error,
            cityError: controller.cityError,
            stateError: controller.stateError,
            zipError: controller.zipError,
            hasError:
                controller.firstNameError.value != null ||
                controller.lastNameError.value != null ||
                controller.emailError.value != null ||
                controller.address1Error.value != null ||
                controller.cityError.value != null ||
                controller.stateError.value != null ||
                controller.zipError.value != null,
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Phones Section
        Obx(
          () => PhonesSection(
            phoneEntries: formState.phoneEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final phone = entry.value;
              return PhoneEntry(
                countryCodeController: phone.countryCodeController,
                numberController: phone.numberController,
                numberError: controller.phoneErrors[index],
              );
            }).toList(),
            onCountryCodeChanged: (index, countryCode) {
              // Update handled by controller
            },
            onNumberChanged: (index, number) {
              controller.validatePhoneNumber(index, number);
            },
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
                _hasPhonesErrors() || controller.phonesError.value != null,
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Specialty Section
        Obx(
          () => SpecialtySection(
            selectedProfession: formState.selectedProfession,
            selectedSpecialties: formState.selectedSpecialties,
            onProfessionChanged: (value) {
              setState(() {
                formState.selectedProfession = value;
              });
              controller.validateProfession(value);
            },
            onSpecialtiesChanged: (specialties) {
              setState(() {
                formState.selectedSpecialties.clear();
                formState.selectedSpecialties.addAll(specialties);
              });
              // Validate as comma-separated string for validation
              final specialtiesString = specialties.join(', ');
              controller.validateSpecialties(specialtiesString);
            },
            professionError: controller.professionError,
            specialtiesError: controller.specialtiesError,
            hasError:
                controller.professionError.value != null ||
                controller.specialtiesError.value != null,
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
              controller.validateLicensureState(value);
            },
            stateError: controller.licensureStateError,
            hasError: controller.licensureStateError.value != null,
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
                  institutionController:
                      formState.educationEntries[index].institutionController,
                  degreeController:
                      formState.educationEntries[index].degreeController,
                  fromDateController:
                      formState.educationEntries[index].fromDateController,
                  toDateController:
                      formState.educationEntries[index].toDateController,
                  isOngoing: isOngoing,
                );
              });
            },
            onInstitutionChanged: (index, institution) {
              controller.validateEducationField(
                index,
                'institutionName',
                institution,
              );
            },
            onDegreeChanged: (index, degree) {
              controller.validateEducationField(index, 'degree', degree);
            },
            onFromDateChanged: (index, fromDate) {
              // No validation needed
            },
            onToDateChanged: (index, toDate) {
              // No validation needed
            },
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
            getFieldError: (index, fieldName) =>
                controller.getEducationFieldError(index, fieldName),
            generalError: controller.educationError,
            hasError: controller.educationError.value != null,
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
                expiryController:
                    formState.certificationEntries[index].expiryController,
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
                  companyController:
                      formState.workHistoryEntries[index].companyController,
                  positionController:
                      formState.workHistoryEntries[index].positionController,
                  descriptionController:
                      formState.workHistoryEntries[index].descriptionController,
                  fromDateController:
                      formState.workHistoryEntries[index].fromDateController,
                  toDateController:
                      formState.workHistoryEntries[index].toDateController,
                  isOngoing: isOngoing,
                );
              });
            },
            onCompanyChanged: (index, company) {
              controller.validateWorkHistoryField(index, 'company', company);
            },
            onPositionChanged: (index, position) {
              controller.validateWorkHistoryField(index, 'position', position);
            },
            onFromDateChanged: (index, fromDate) {
              // No validation needed
            },
            onToDateChanged: (index, toDate) {
              // No validation needed
            },
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
            hasError: controller.workHistoryError.value != null,
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
            text: AppTexts.saveProfile,
            onPressed: () {
              ProfileFormDataHelper.saveProfileData(controller, formState);
            },
            isLoading: controller.isLoading.value,
          ),
        ),
      ],
    );
  }
}
