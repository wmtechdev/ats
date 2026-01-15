import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/presentation/admin/controllers/admin_create_candidate_controller.dart';

class AdminCreateCandidateScreen extends StatefulWidget {
  const AdminCreateCandidateScreen({super.key});

  @override
  State<AdminCreateCandidateScreen> createState() => _AdminCreateCandidateScreenState();
}

class _AdminCreateCandidateScreenState extends State<AdminCreateCandidateScreen> {
  late final AdminCreateCandidateController _controller;
  Widget? _cachedForm;
  final _formKey = GlobalKey(debugLabel: 'admin-create-candidate-form');

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminCreateCandidateController>();
  }

  @override
  Widget build(BuildContext context) {
    _cachedForm ??= SingleChildScrollView(
      key: const ValueKey('admin-create-candidate-scroll-view'),
      padding: AppSpacing.padding(context),
      child: Column(
        key: _formKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Candidate Profile Section
          CandidateProfileSection(
            firstNameController: _controller.formState.firstNameController,
            middleNameController: _controller.formState.middleNameController,
            lastNameController: _controller.formState.lastNameController,
            emailController: _controller.formState.emailController,
            passwordController: _controller.passwordController,
            emailEnabled: true, // Email is editable in admin create
            passwordEnabled: true, // Password is editable in admin create
            address1Controller: _controller.formState.address1Controller,
            address2Controller: _controller.formState.address2Controller,
            cityController: _controller.formState.cityController,
            stateController: _controller.formState.stateController,
            zipController: _controller.formState.zipController,
            ssnController: _controller.formState.ssnController,
            firstNameError: _controller.firstNameError,
            lastNameError: _controller.lastNameError,
            emailError: _controller.emailError,
            passwordError: _controller.passwordError,
            passwordValue: _controller.passwordValue.value,
            address1Error: _controller.address1Error,
            cityError: _controller.cityError,
            stateError: _controller.stateError,
            zipError: _controller.zipError,
            onFirstNameChanged: (value) {
              _controller.validateFirstName(value);
              return null;
            },
            onLastNameChanged: (value) {
              _controller.validateLastName(value);
              return null;
            },
            onEmailChanged: (value) {
              _controller.validateEmail(value);
              return null;
            },
            onPasswordChanged: (value) {
              _controller.validatePassword(value);
              return null;
            },
            onAddress1Changed: (value) {
              _controller.validateAddress1(value);
              return null;
            },
            onCityChanged: (value) {
              _controller.validateCity(value);
              return null;
            },
            onStateChanged: (value) {
              _controller.validateState(value);
              return null;
            },
            onZipChanged: (value) {
              _controller.validateZip(value);
              return null;
            },
            hasError: false, // Individual error messages are already wrapped in Obx
          ),
            AppSpacing.vertical(context, 0.02),

          AppSpacing.vertical(context, 0.02),

          // Phones Section
          Obx(() {
            // Access trigger to ensure rebuild when list changes
            _controller.phonesListTrigger.value;
            return PhonesSection(
              phoneEntries: _controller.formState.phoneEntries
                    .asMap()
                    .entries
                    .map((entry) {
                final index = entry.key;
                final phone = entry.value;
                final error = _controller.phoneErrors[index];
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
                _controller.validatePhoneNumber(index, number);
              },
              onAddPhone: () {
                _controller.formState.addPhone();
                _controller.updateListTriggers();
              },
              onRemovePhone: (index) {
                _controller.formState.removePhone(index);
                _controller.updateListTriggers();
              },
              hasError:
                  _controller.phonesError.value != null ||
                  _controller.phoneErrors.values.any((e) => e.value != null),
            );
          }),
          AppSpacing.vertical(context, 0.02),

          // Specialty Section
          Obx(
            () => SpecialtySection(
              selectedProfession: _controller.formState.selectedProfession,
              selectedSpecialties: _controller.formState.selectedSpecialties,
              professionError: _controller.professionError,
              specialtiesError: _controller.specialtiesError,
              onProfessionChanged: (value) {
                _controller.formState.selectedProfession = value;
                _controller.validateProfession(value);
              },
              onSpecialtiesChanged: (specialties) {
                _controller.formState.selectedSpecialties.clear();
                _controller.formState.selectedSpecialties.addAll(specialties);
                _controller.validateSpecialties(specialties.join(', '));
              },
              hasError:
                  _controller.professionError.value != null ||
                  _controller.specialtiesError.value != null,
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Background History Section
          BackgroundHistorySection(
            liabilityAction: _controller.formState.liabilityAction,
            licenseAction: _controller.formState.licenseAction,
            previouslyTraveled: _controller.formState.previouslyTraveled,
            terminatedFromAssignment:
                _controller.formState.terminatedFromAssignment,
            onLiabilityActionChanged: (value) {
              _controller.formState.liabilityAction = value;
            },
            onLicenseActionChanged: (value) {
              _controller.formState.licenseAction = value;
            },
            onPreviouslyTraveledChanged: (value) {
              _controller.formState.previouslyTraveled = value;
            },
            onTerminatedFromAssignmentChanged: (value) {
              _controller.formState.terminatedFromAssignment = value;
            },
          ),
          AppSpacing.vertical(context, 0.02),

          // Licensure Section
          Obx(
            () => LicensureSection(
              selectedState: _controller.formState.licensureState,
              npiController: _controller.formState.npiController,
              onStateChanged: (value) {
                _controller.formState.licensureState = value;
                _controller.validateLicensureState(value);
              },
              stateError: _controller.licensureStateError,
              hasError: _controller.licensureStateError.value != null,
            ),
          ),
          AppSpacing.vertical(context, 0.02),

          // Education Section
          Obx(() {
            // Access trigger to ensure rebuild when list changes
            _controller.educationListTrigger.value;
            return EducationSection(
              educationEntries: _controller.formState.educationEntries,
              onOngoingChanged: (index, isOngoing) {
                _controller.formState.educationEntries[index] = EducationEntry(
                  institutionController: _controller
                      .formState
                      .educationEntries[index]
                      .institutionController,
                  degreeController: _controller
                      .formState
                      .educationEntries[index]
                      .degreeController,
                  fromDateController: _controller
                      .formState
                      .educationEntries[index]
                      .fromDateController,
                  toDateController: _controller
                      .formState
                      .educationEntries[index]
                      .toDateController,
                  isOngoing: isOngoing,
                );
                // Trigger rebuild to show/hide "To Date" field
                _controller.updateListTriggers();
              },
              onInstitutionChanged: (index, institution) {},
              onDegreeChanged: (index, degree) {},
              onFromDateChanged: (index, fromDate) {},
              onToDateChanged: (index, toDate) {},
              onAddEducation: () {
                _controller.formState.addEducation();
                _controller.updateListTriggers();
              },
              onRemoveEducation: (index) {
                _controller.formState.removeEducation(index);
                _controller.updateListTriggers();
              },
              generalError: _controller.educationError,
              hasError: _controller.educationError.value != null,
            );
          }),
          AppSpacing.vertical(context, 0.02),

          // Certifications Section
          Obx(() {
            // Access trigger to ensure rebuild when list changes
            _controller.certificationsListTrigger.value;
            return CertificationsSection(
              certificationEntries: _controller.formState.certificationEntries,
              onNoExpiryChanged: (index, hasNoExpiry) {
                _controller.formState.certificationEntries[index] =
                    CertificationEntry(
                      nameController: _controller
                          .formState
                          .certificationEntries[index]
                          .nameController,
                      expiryController: _controller
                          .formState
                          .certificationEntries[index]
                          .expiryController,
                      hasNoExpiry: hasNoExpiry,
                    );
                // Trigger rebuild to show/hide expiry field
                _controller.updateListTriggers();
              },
              onAddCertification: () {
                _controller.formState.addCertification();
                _controller.updateListTriggers();
              },
              onRemoveCertification: (index) {
                _controller.formState.removeCertification(index);
                _controller.updateListTriggers();
              },
            );
          }),
          AppSpacing.vertical(context, 0.02),

          // Work History Section
          Obx(() {
            // Access trigger to ensure rebuild when list changes
            _controller.workHistoryListTrigger.value;
            return WorkHistorySectionWidget(
              workHistoryEntries: _controller.formState.workHistoryEntries,
              onOngoingChanged: (index, isOngoing) {
                _controller.formState.workHistoryEntries[index] =
                    WorkHistoryEntry(
                      companyController: _controller
                          .formState
                          .workHistoryEntries[index]
                          .companyController,
                      positionController: _controller
                          .formState
                          .workHistoryEntries[index]
                          .positionController,
                      descriptionController: _controller
                          .formState
                          .workHistoryEntries[index]
                          .descriptionController,
                      fromDateController: _controller
                          .formState
                          .workHistoryEntries[index]
                          .fromDateController,
                      toDateController: _controller
                          .formState
                          .workHistoryEntries[index]
                          .toDateController,
                      isOngoing: isOngoing,
                    );
                // Trigger rebuild to show/hide "To Date" field
                _controller.updateListTriggers();
              },
              onCompanyChanged: (index, company) {},
              onPositionChanged: (index, position) {},
              onFromDateChanged: (index, fromDate) {},
              onToDateChanged: (index, toDate) {},
              onAdd: () {
                _controller.formState.addWorkHistoryEntry();
                _controller.updateListTriggers();
              },
              onRemove: (index) {
                _controller.formState.removeWorkHistoryEntry(index);
                _controller.updateListTriggers();
              },
              generalError: _controller.workHistoryError,
              hasError: _controller.workHistoryError.value != null,
            );
          }),
          AppSpacing.vertical(context, 0.03),

          // Error Message
          Obx(
            () => _controller.errorMessage.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: AppResponsive.screenHeight(context) * 0.02,
                    ),
                    child: AppErrorMessage(
                      message: _controller.errorMessage.value,
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
              onPressed: _controller.createCandidate,
              isLoading: _controller.isLoading.value,
            ),
          ),
        ],
      ),
    );

    return AppAdminLayout(
      title: AppTexts.createCandidate,
      child: _cachedForm!,
    );
  }
}
