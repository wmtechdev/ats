import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';

class AppCandidatesTable extends StatelessWidget {
  final List<UserEntity> candidates;
  final String Function(String userId) getName;
  final String Function(String userId) getCompany;
  final String Function(String userId) getPosition;
  final String Function(String userId) getStatus;
  final String Function(String userId) getAgentName;
  final String? Function(String userId) getAssignedAgentProfileId;
  final Function(UserEntity) onCandidateTap;
  final bool isSuperAdmin;
  final List<AdminProfileEntity> availableAgents;
  final Future<void> Function(String userId, String? agentId) onAgentChanged;

  const AppCandidatesTable({
    super.key,
    required this.candidates,
    required this.getName,
    required this.getCompany,
    required this.getPosition,
    required this.getStatus,
    required this.getAgentName,
    required this.getAssignedAgentProfileId,
    required this.onCandidateTap,
    required this.isSuperAdmin,
    required this.availableAgents,
    required this.onAgentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.padding(context).copyWith(left: 0, right: 0),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(AppColors.lightGrey),
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.name,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.email,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.company,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.position,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.status,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  AppTexts.agent,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          rows: candidates.map((candidate) {
            final name = getName(candidate.userId);
            final company = getCompany(candidate.userId);
            final position = getPosition(candidate.userId);
            final status = getStatus(candidate.userId);
            final agentName = getAgentName(candidate.userId);

            return DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        name,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        candidate.email,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        company,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        position,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: InkWell(
                      onTap: () => onCandidateTap(candidate),
                      child: Text(
                        _formatStatus(status),
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: isSuperAdmin
                        ? _buildAgentDropdown(context, candidate.userId, agentName, getAssignedAgentProfileId(candidate.userId))
                        : Text(
                            agentName,
                            style: AppTextStyles.bodyText(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case AppConstants.documentStatusApproved:
        return AppTexts.approved;
      case AppConstants.documentStatusDenied:
        return AppTexts.denied;
      case AppConstants.documentStatusPending:
      default:
        return AppTexts.pending;
    }
  }

  Widget _buildAgentDropdown(BuildContext context, String userId, String currentAgentName, String? assignedAgentProfileId) {
    // Use the assignedAgentProfileId directly from the candidate profile
    // This is the profileId of the admin profile assigned to this candidate
    String? currentAgentProfileId = assignedAgentProfileId;
    
    // Validate that the profileId exists in available agents
    if (currentAgentProfileId != null && currentAgentProfileId.isNotEmpty) {
      final agentExists = availableAgents.any((a) => a.profileId == currentAgentProfileId);
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
              color: AppColors.secondary.withOpacity(0.5),
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
      onChanged: availableAgents.isEmpty
          ? null // Disable dropdown if no agents available
          : (String? newAgentProfileId) {
              if (newAgentProfileId != currentAgentProfileId && newAgentProfileId != '') {
                onAgentChanged(userId, newAgentProfileId);
              }
            },
    );
  }
}
