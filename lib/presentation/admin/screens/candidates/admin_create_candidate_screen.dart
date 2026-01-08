import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/profile/sections/sections.dart';
import 'package:ats/presentation/admin/controllers/admin_create_candidate_controller.dart';

class AdminCreateCandidateScreen extends StatelessWidget {
  const AdminCreateCandidateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCreateCandidateController>();

    return AppAdminLayout(
      title: AppTexts.createCandidate,
      child: SingleChildScrollView(
        padding: AppSpacing.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Candidate Profile Section
            Obx(
              () => CandidateProfileSection(
                firstNameController: controller.formState.firstNameController,
                middleNameController: controller.formState.middleNameController,
                lastNameController: controller.formState.lastNameController,
                emailController: controller.formState.emailController,
                passwordController: controller.passwordController,
                emailEnabled: true, // Email is editable in admin create
                passwordEnabled: true, // Password is editable in admin create
                address1Controller: controller.formState.address1Controller,
                address2Controller: controller.formState.address2Controller,
                cityController: controller.formState.cityController,
                stateController: controller.formState.stateController,
                zipController: controller.formState.zipController,
                ssnController: controller.formState.ssnController,
                firstNameError: controller.firstNameError,
                lastNameError: controller.lastNameError,
                emailError: controller.emailError,
                passwordError: controller.passwordError,
                address1Error: controller.address1Error,
                cityError: controller.cityError,
                stateError: controller.stateError,
                zipError: controller.zipError,
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
                onPasswordChanged: (value) {
                  controller.validatePassword(value);
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
                hasError:
                    controller.firstNameError.value != null ||
                    controller.lastNameError.value != null ||
                    controller.emailError.value != null ||
                    controller.passwordError.value != null ||
                    controller.address1Error.value != null ||
                    controller.cityError.value != null ||
                    controller.stateError.value != null ||
                    controller.zipError.value != null,
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Phones Section
            Obx(() {
              // Access trigger to ensure rebuild when list changes
              controller.phonesListTrigger.value;
              return PhonesSection(
                phoneEntries: controller.formState.phoneEntries
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final phone = entry.value;
                      final error = controller.phoneErrors[index];
                      return PhoneEntry(
                        countryCodeController: phone.countryCodeController,
                        numberController: phone.numberController,
                        numberError: error ?? Rxn<String>(null),
                      );
                    })
                    .toList(),
                onCountryCodeChanged: (index, countryCode) {
                  // Update handled by controller
                },
                onNumberChanged: (index, number) {
                  controller.validatePhoneNumber(index, number);
                },
                onAddPhone: () {
                  controller.formState.addPhone();
                  controller.updateListTriggers();
                },
                onRemovePhone: (index) {
                  controller.formState.removePhone(index);
                  controller.updateListTriggers();
                },
                hasError:
                    controller.phonesError.value != null ||
                    controller.phoneErrors.values.any((e) => e.value != null),
              );
            }),
            AppSpacing.vertical(context, 0.02),

            // Specialty Section
            Obx(
              () => SpecialtySection(
                selectedProfession: controller.formState.selectedProfession,
                selectedSpecialties: controller.formState.selectedSpecialties,
                professionError: controller.professionError,
                specialtiesError: controller.specialtiesError,
                onProfessionChanged: (value) {
                  controller.formState.selectedProfession = value;
                  controller.validateProfession(value);
                },
                onSpecialtiesChanged: (specialties) {
                  controller.formState.selectedSpecialties.clear();
                  controller.formState.selectedSpecialties.addAll(specialties);
                  controller.validateSpecialties(specialties.join(', '));
                },
                hasError:
                    controller.professionError.value != null ||
                    controller.specialtiesError.value != null,
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Background History Section
            BackgroundHistorySection(
              liabilityAction: controller.formState.liabilityAction,
              licenseAction: controller.formState.licenseAction,
              previouslyTraveled: controller.formState.previouslyTraveled,
              terminatedFromAssignment:
                  controller.formState.terminatedFromAssignment,
              onLiabilityActionChanged: (value) {
                controller.formState.liabilityAction = value;
              },
              onLicenseActionChanged: (value) {
                controller.formState.licenseAction = value;
              },
              onPreviouslyTraveledChanged: (value) {
                controller.formState.previouslyTraveled = value;
              },
              onTerminatedFromAssignmentChanged: (value) {
                controller.formState.terminatedFromAssignment = value;
              },
            ),
            AppSpacing.vertical(context, 0.02),

            // Licensure Section
            Obx(
              () => LicensureSection(
                selectedState: controller.formState.licensureState,
                npiController: controller.formState.npiController,
                onStateChanged: (value) {
                  controller.formState.licensureState = value;
                  controller.validateLicensureState(value);
                },
                stateError: controller.licensureStateError,
                hasError: controller.licensureStateError.value != null,
              ),
            ),
            AppSpacing.vertical(context, 0.02),

            // Education Section
            Obx(() {
              // Access trigger to ensure rebuild when list changes
              controller.educationListTrigger.value;
              return EducationSection(
                educationEntries: controller.formState.educationEntries,
                onOngoingChanged: (index, isOngoing) {
                  controller.formState.educationEntries[index] = EducationEntry(
                    institutionController: controller
                        .formState
                        .educationEntries[index]
                        .institutionController,
                    degreeController: controller
                        .formState
                        .educationEntries[index]
                        .degreeController,
                    fromDateController: controller
                        .formState
                        .educationEntries[index]
                        .fromDateController,
                    toDateController: controller
                        .formState
                        .educationEntries[index]
                        .toDateController,
                    isOngoing: isOngoing,
                  );
                  // Trigger rebuild to show/hide "To Date" field
                  controller.updateListTriggers();
                },
                onInstitutionChanged: (index, institution) {},
                onDegreeChanged: (index, degree) {},
                onFromDateChanged: (index, fromDate) {},
                onToDateChanged: (index, toDate) {},
                onAddEducation: () {
                  controller.formState.addEducation();
                  controller.updateListTriggers();
                },
                onRemoveEducation: (index) {
                  controller.formState.removeEducation(index);
                  controller.updateListTriggers();
                },
                generalError: controller.educationError,
                hasError: controller.educationError.value != null,
              );
            }),
            AppSpacing.vertical(context, 0.02),

            // Certifications Section
            Obx(() {
              // Access trigger to ensure rebuild when list changes
              controller.certificationsListTrigger.value;
              return CertificationsSection(
                certificationEntries: controller.formState.certificationEntries,
                onNoExpiryChanged: (index, hasNoExpiry) {
                  controller.formState.certificationEntries[index] =
                      CertificationEntry(
                        nameController: controller
                            .formState
                            .certificationEntries[index]
                            .nameController,
                        expiryController: controller
                            .formState
                            .certificationEntries[index]
                            .expiryController,
                        hasNoExpiry: hasNoExpiry,
                      );
                  // Trigger rebuild to show/hide expiry field
                  controller.updateListTriggers();
                },
                onAddCertification: () {
                  controller.formState.addCertification();
                  controller.updateListTriggers();
                },
                onRemoveCertification: (index) {
                  controller.formState.removeCertification(index);
                  controller.updateListTriggers();
                },
              );
            }),
            AppSpacing.vertical(context, 0.02),

            // Work History Section
            Obx(() {
              // Access trigger to ensure rebuild when list changes
              controller.workHistoryListTrigger.value;
              return WorkHistorySectionWidget(
                workHistoryEntries: controller.formState.workHistoryEntries,
                onOngoingChanged: (index, isOngoing) {
                  controller.formState.workHistoryEntries[index] =
                      WorkHistoryEntry(
                        companyController: controller
                            .formState
                            .workHistoryEntries[index]
                            .companyController,
                        positionController: controller
                            .formState
                            .workHistoryEntries[index]
                            .positionController,
                        descriptionController: controller
                            .formState
                            .workHistoryEntries[index]
                            .descriptionController,
                        fromDateController: controller
                            .formState
                            .workHistoryEntries[index]
                            .fromDateController,
                        toDateController: controller
                            .formState
                            .workHistoryEntries[index]
                            .toDateController,
                        isOngoing: isOngoing,
                      );
                  // Trigger rebuild to show/hide "To Date" field
                  controller.updateListTriggers();
                },
                onCompanyChanged: (index, company) {},
                onPositionChanged: (index, position) {},
                onFromDateChanged: (index, fromDate) {},
                onToDateChanged: (index, toDate) {},
                onAdd: () {
                  controller.formState.addWorkHistoryEntry();
                  controller.updateListTriggers();
                },
                onRemove: (index) {
                  controller.formState.removeWorkHistoryEntry(index);
                  controller.updateListTriggers();
                },
                generalError: controller.workHistoryError,
                hasError: controller.workHistoryError.value != null,
              );
            }),
            AppSpacing.vertical(context, 0.03),

            // Error Message
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: AppResponsive.screenHeight(context) * 0.02,
                      ),
                      child: AppErrorMessage(
                        message: controller.errorMessage.value,
                        icon: Iconsax.info_circle,
                        messageColor: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Create Button
            Obx(
              () => AppButton(
                text: AppTexts.createCandidate,
                onPressed: controller.createCandidate,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
