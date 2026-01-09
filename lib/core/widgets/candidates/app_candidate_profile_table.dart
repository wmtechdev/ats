import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';

class AppCandidateProfileTable extends StatelessWidget {
  final CandidateProfileEntity? profile;
  final String? fallbackEmail;
  final int documentsCount;
  final int applicationsCount;
  final String agentName;
  final bool isSuperAdmin;
  final List<AdminProfileEntity> availableAgents;
  final String? assignedAgentProfileId;
  final Future<void> Function(String? agentProfileId)? onAgentChanged;
  final String userId;

  const AppCandidateProfileTable({
    super.key,
    required this.profile,
    this.fallbackEmail,
    required this.documentsCount,
    required this.applicationsCount,
    required this.agentName,
    required this.isSuperAdmin,
    required this.availableAgents,
    this.assignedAgentProfileId,
    this.onAgentChanged,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context).copyWith(left: 0, right: 0),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
          dataRowMinHeight: 40.0,
          dataRowMaxHeight: double.infinity,
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  AppTexts.field,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  AppTexts.value,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          rows: _buildProfileRows(context),
        ),
      ),
    );
  }

  List<DataRow> _buildProfileRows(BuildContext context) {
    if (profile == null) {
      return [
        DataRow(
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  'Profile',
                  style: AppTextStyles.bodyText(context),
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  'No profile data available',
                  style: AppTextStyles.bodyText(context),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    final rows = <DataRow>[];

    // ========== Candidate Profile Section ==========
    rows.add(_buildDataRow(
      context,
      AppTexts.candidateProfile,
      '',
      isSectionHeader: true,
    ));

    // Full Name (combining First, Middle, and Last Name)
    final fullName = _getFullName();
    rows.add(_buildDataRow(
      context,
      AppTexts.name,
      fullName,
    ));

    // Email
    final email = profile!.email ?? fallbackEmail ?? 'N/A';
    rows.add(_buildDataRow(
      context,
      AppTexts.email,
      email,
    ));

    // Full Address (if all components exist)
    final fullAddress = _getFullAddress();
    if (fullAddress.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.address,
        fullAddress,
        isMultiline: true,
      ));
    } else {
      // Show individual address components if full address not available
      if (profile!.address1 != null && profile!.address1!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.address1,
          profile!.address1!,
        ));
      }

      if (profile!.address2 != null && profile!.address2!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.address2,
          profile!.address2!,
        ));
      }

      if (profile!.city != null && profile!.city!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.city,
          profile!.city!,
        ));
      }

      if (profile!.state != null && profile!.state!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.state,
          profile!.state!,
        ));
      }

      if (profile!.zip != null && profile!.zip!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.zip,
          profile!.zip!,
        ));
      }
    }

    // SSN
    if (profile!.ssn != null && profile!.ssn!.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.ssn,
        profile!.ssn!,
      ));
    }

    // ========== Phones Section ==========
    final phonesText = _formatPhones();
    if (phonesText.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.phones,
        '',
        isSectionHeader: true,
      ));
      rows.add(_buildDataRow(
        context,
        AppTexts.phoneNumber,
        phonesText,
        isMultiline: true,
      ));
    }

    // ========== Specialty Section ==========
    if ((profile!.profession != null && profile!.profession!.isNotEmpty) ||
        (profile!.specialties != null && profile!.specialties!.isNotEmpty)) {
      rows.add(_buildDataRow(
        context,
        AppTexts.specialty,
        '',
        isSectionHeader: true,
      ));

      // Profession
      if (profile!.profession != null && profile!.profession!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.profession,
          profile!.profession!,
        ));
      }

      // Specialties
      if (profile!.specialties != null && profile!.specialties!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.specialties,
          profile!.specialties!,
        ));
      }
    }

    // ========== Background History Section ==========
    if (profile!.liabilityAction != null ||
        profile!.licenseAction != null ||
        profile!.previouslyTraveled != null ||
        profile!.terminatedFromAssignment != null) {
      rows.add(_buildDataRow(
        context,
        AppTexts.backgroundHistory,
        '',
        isSectionHeader: true,
      ));

      // Liability Action
      if (profile!.liabilityAction != null &&
          profile!.liabilityAction!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.liabilityAction,
          profile!.liabilityAction == 'Yes' ? AppTexts.yes : AppTexts.no,
        ));
      }

      // License Action
      if (profile!.licenseAction != null &&
          profile!.licenseAction!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.licenseAction,
          profile!.licenseAction == 'Yes' ? AppTexts.yes : AppTexts.no,
        ));
      }

      // Previously Traveled
      if (profile!.previouslyTraveled != null &&
          profile!.previouslyTraveled!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.previouslyTraveled,
          profile!.previouslyTraveled == 'Yes' ? AppTexts.yes : AppTexts.no,
        ));
      }

      // Terminated From Assignment
      if (profile!.terminatedFromAssignment != null &&
          profile!.terminatedFromAssignment!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.terminatedFromAssignment,
          profile!.terminatedFromAssignment == 'Yes'
              ? AppTexts.yes
              : AppTexts.no,
        ));
      }
    }

    // ========== Licensure Section ==========
    if ((profile!.licensureState != null &&
            profile!.licensureState!.isNotEmpty) ||
        (profile!.npi != null && profile!.npi!.isNotEmpty)) {
      rows.add(_buildDataRow(
        context,
        AppTexts.licensure,
        '',
        isSectionHeader: true,
      ));

      // Licensure State
      if (profile!.licensureState != null &&
          profile!.licensureState!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.state,
          profile!.licensureState!,
        ));
      }

      // NPI
      if (profile!.npi != null && profile!.npi!.isNotEmpty) {
        rows.add(_buildDataRow(
          context,
          AppTexts.npi,
          profile!.npi!,
        ));
      }
    }

    // ========== Background History Section ==========
    rows.add(_buildDataRow(
      context,
      AppTexts.backgroundHistory,
      '',
      isSectionHeader: true,
    ));

    // Liability Action
    if (profile!.liabilityAction != null &&
        profile!.liabilityAction!.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.liabilityAction,
        profile!.liabilityAction == 'Yes' ? AppTexts.yes : AppTexts.no,
      ));
    }

    // License Action
    if (profile!.licenseAction != null && profile!.licenseAction!.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.licenseAction,
        profile!.licenseAction == 'Yes' ? AppTexts.yes : AppTexts.no,
      ));
    }

    // Previously Traveled
    if (profile!.previouslyTraveled != null &&
        profile!.previouslyTraveled!.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.previouslyTraveled,
        profile!.previouslyTraveled == 'Yes' ? AppTexts.yes : AppTexts.no,
      ));
    }

    // Terminated From Assignment
    if (profile!.terminatedFromAssignment != null &&
        profile!.terminatedFromAssignment!.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.terminatedFromAssignment,
        profile!.terminatedFromAssignment == 'Yes'
            ? AppTexts.yes
            : AppTexts.no,
      ));
    }

    // ========== Work History Section ==========
    final workHistoryText = _formatWorkHistory();
    if (workHistoryText.isNotEmpty && workHistoryText != 'No work history') {
      rows.add(_buildDataRow(
        context,
        AppTexts.workHistory,
        '',
        isSectionHeader: true,
      ));
      rows.add(_buildDataRow(
        context,
        '',
        workHistoryText,
        isMultiline: true,
      ));
    }

    // ========== Education Section ==========
    final educationText = _formatEducation();
    if (educationText.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.education,
        '',
        isSectionHeader: true,
      ));
      rows.add(_buildDataRow(
        context,
        '',
        educationText,
        isMultiline: true,
      ));
    }

    // ========== Certifications Section ==========
    final certificationsText = _formatCertifications();
    if (certificationsText.isNotEmpty) {
      rows.add(_buildDataRow(
        context,
        AppTexts.certifications,
        '',
        isSectionHeader: true,
      ));
      rows.add(_buildDataRow(
        context,
        '',
        certificationsText,
        isMultiline: true,
      ));
    }

    // ========== Statistics Section ==========
    rows.add(_buildDataRow(
      context,
      'Statistics',
      '',
      isSectionHeader: true,
    ));

    // Documents Count
    rows.add(_buildDataRow(
      context,
      AppTexts.documentsUploadedCount,
      documentsCount.toString(),
    ));

    // Applications Count
    rows.add(_buildDataRow(
      context,
      AppTexts.jobsAppliedCount,
      applicationsCount.toString(),
    ));

    // ========== Assignment Section ==========
    rows.add(_buildDataRow(
      context,
      'Agent Assignment',
      '',
      isSectionHeader: true,
    ));

    // Agent
    rows.add(DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: Text(
              AppTexts.agent,
              style: AppTextStyles.bodyText(context),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: isSuperAdmin && onAgentChanged != null
                ? _buildAgentDropdown(
                    context,
                    userId,
                    agentName,
                    assignedAgentProfileId,
                  )
                : Text(
                    agentName,
                    style: AppTextStyles.bodyText(context),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ],
    ));

    return rows;
  }

  DataRow _buildDataRow(
    BuildContext context,
    String fieldLabel,
    String value, {
    bool isMultiline = false,
    bool isSectionHeader = false,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMultiline ? 12.0 : 8.0,
              horizontal: 4.0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: fieldLabel.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      fieldLabel,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: isSectionHeader
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSectionHeader
                            ? AppColors.secondary
                            : null,
                      ),
                    ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMultiline ? 12.0 : 8.0,
              horizontal: 4.0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: isMultiline
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Text(
                        value,
                        style: AppTextStyles.bodyText(context).copyWith(
                          height: 1.5, // Line height for better readability
                        ),
                        maxLines: null,
                        softWrap: true,
                      ),
                    )
                  : Text(
                      value,
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _getFullName() {
    if (profile == null) return 'N/A';
    final parts = <String>[
      profile!.firstName,
      if (profile!.middleName != null && profile!.middleName!.isNotEmpty)
        profile!.middleName!,
      profile!.lastName,
    ];
    return parts.join(' ').trim();
  }

  String _getFullAddress() {
    if (profile == null) return '';
    final parts = <String>[];
    if (profile!.address1 != null && profile!.address1!.isNotEmpty) {
      parts.add(profile!.address1!);
    }
    if (profile!.address2 != null && profile!.address2!.isNotEmpty) {
      parts.add(profile!.address2!);
    }
    final cityStateZip = <String>[];
    if (profile!.city != null && profile!.city!.isNotEmpty) {
      cityStateZip.add(profile!.city!);
    }
    if (profile!.state != null && profile!.state!.isNotEmpty) {
      cityStateZip.add(profile!.state!);
    }
    if (profile!.zip != null && profile!.zip!.isNotEmpty) {
      cityStateZip.add(profile!.zip!);
    }
    if (cityStateZip.isNotEmpty) {
      parts.add(cityStateZip.join(', '));
    }
    return parts.join('\n');
  }

  String _formatPhones() {
    if (profile == null ||
        profile!.phones == null ||
        profile!.phones!.isEmpty) {
      return '';
    }
    return profile!.phones!
        .map((phone) {
          final countryCode = phone['countryCode']?.toString() ?? '';
          final number = phone['number']?.toString() ?? '';
          if (number.isEmpty) return null;
          return countryCode.isNotEmpty
              ? '$countryCode $number'
              : number;
        })
        .where((phone) => phone != null)
        .join('\n');
  }

  String _formatWorkHistory() {
    if (profile == null ||
        profile!.workHistory == null ||
        profile!.workHistory!.isEmpty) {
      return 'No work history';
    }
    return profile!.workHistory!
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final work = entry.value;
          final company = work['company']?.toString() ?? 'N/A';
          final position = work['position']?.toString() ?? 'N/A';
          final fromDate = work['fromDate']?.toString() ?? '';
          final toDate = work['toDate']?.toString() ?? '';
          final isOngoing = work['isOngoing'] == true;
          final description = work['description']?.toString() ?? '';

          final dateRange = isOngoing
              ? '$fromDate - ${AppTexts.ongoing}'
              : (fromDate.isNotEmpty && toDate.isNotEmpty
                  ? '$fromDate - $toDate'
                  : fromDate.isNotEmpty
                      ? fromDate
                      : '');

          final parts = <String>[
            '${index + 1}. $company - $position',
            if (dateRange.isNotEmpty) dateRange,
            if (description.isNotEmpty) description,
          ];

          return parts.join('\n');
        })
        .join('\n\n');
  }

  String _formatEducation() {
    if (profile == null ||
        profile!.education == null ||
        profile!.education!.isEmpty) {
      return '';
    }
    return profile!.education!
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final edu = entry.value;
          final institution = edu['institutionName']?.toString() ?? 'N/A';
          final degree = edu['degree']?.toString() ?? 'N/A';
          final fromDate = edu['fromDate']?.toString() ?? '';
          final toDate = edu['toDate']?.toString() ?? '';
          final isOngoing = edu['isOngoing'] == true;

          final dateRange = isOngoing
              ? '$fromDate - ${AppTexts.ongoing}'
              : (fromDate.isNotEmpty && toDate.isNotEmpty
                  ? '$fromDate - $toDate'
                  : fromDate.isNotEmpty
                      ? fromDate
                      : '');

          final parts = <String>[
            '${index + 1}. $institution',
            if (degree.isNotEmpty && degree != 'N/A') degree,
            if (dateRange.isNotEmpty) dateRange,
          ];

          return parts.join('\n');
        })
        .join('\n\n');
  }

  String _formatCertifications() {
    if (profile == null ||
        profile!.certifications == null ||
        profile!.certifications!.isEmpty) {
      return '';
    }
    return profile!.certifications!
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final cert = entry.value;
          final name = cert['name']?.toString() ?? 'N/A';
          final expiry = cert['expiry']?.toString();
          final hasNoExpiry = cert['hasNoExpiry'] == true;

          final parts = <String>[
            '${index + 1}. $name',
            if (hasNoExpiry)
              AppTexts.ongoing
            else if (expiry != null && expiry.isNotEmpty)
              '${AppTexts.expiry}: $expiry',
          ];

          return parts.join('\n');
        })
        .join('\n\n');
  }

  Widget _buildAgentDropdown(
    BuildContext context,
    String userId,
    String currentAgentName,
    String? assignedAgentProfileId,
  ) {
    // Use the assignedAgentProfileId directly from the candidate profile
    // This is the profileId of the admin profile assigned to this candidate
    String? currentAgentProfileId = assignedAgentProfileId;

    // Validate that the profileId exists in available agents
    if (currentAgentProfileId != null && currentAgentProfileId.isNotEmpty) {
      final agentExists = availableAgents.any(
        (a) => a.profileId == currentAgentProfileId,
      );
      if (!agentExists) {
        // If the assigned agent is not in the available list, reset to null
        currentAgentProfileId = null;
      }
    }

    // Build dropdown items
    final items = <DropdownMenuItem<String>>[
      // Add "None" option
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          'None',
          style: AppTextStyles.bodyText(context),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    // Add all available agents
    if (availableAgents.isEmpty) {
      // If no agents available, show a message
      items.add(
        DropdownMenuItem<String>(
          value: '',
          enabled: false,
          child: Text(
            'No agents available',
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.secondary.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      // Add available agents - use profileId as the value
      items.addAll(
        availableAgents.map((agent) {
          return DropdownMenuItem<String>(
            value: agent.profileId,
            child: Text(
              agent.name.isNotEmpty ? agent.name : 'Unknown Agent',
              style: AppTextStyles.bodyText(context),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      );
    }

    return DropdownButton<String>(
      value: currentAgentProfileId,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      hint: Text(
        availableAgents.isEmpty ? 'Loading agents...' : 'Select Agent',
        style: AppTextStyles.bodyText(context),
        overflow: TextOverflow.ellipsis,
      ),
      items: items,
      onChanged: availableAgents.isEmpty || onAgentChanged == null
          ? null // Disable dropdown if no agents available or callback not provided
          : (String? newAgentProfileId) {
              if (newAgentProfileId != currentAgentProfileId &&
                  newAgentProfileId != '') {
                onAgentChanged!(newAgentProfileId);
              }
            },
    );
  }
}
