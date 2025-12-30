import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';

class AppCandidateProfileTable extends StatelessWidget {
  final String name;
  final String email;
  final String workHistory;
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
    required this.name,
    required this.email,
    required this.workHistory,
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
          headingRowColor: MaterialStateProperty.all(AppColors.lightGrey),
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
          rows: [
            DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(AppTexts.name, style: AppTextStyles.bodyText(context)),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      name,
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(AppTexts.email, style: AppTextStyles.bodyText(context)),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      email,
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      AppTexts.workHistory,
                      style: AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Text(
                        workHistory,
                        style: AppTextStyles.bodyText(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      AppTexts.documentsUploadedCount,
                      style: AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      documentsCount.toString(),
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      AppTexts.jobsAppliedCount,
                      style: AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      applicationsCount.toString(),
                      style: AppTextStyles.bodyText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      AppTexts.agent,
                      style: AppTextStyles.bodyText(context),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: isSuperAdmin && onAgentChanged != null
                        ? _buildAgentDropdown(context, userId, agentName, assignedAgentProfileId)
                        : Text(
                            agentName,
                            style: AppTextStyles.bodyText(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      onChanged: availableAgents.isEmpty || onAgentChanged == null
          ? null // Disable dropdown if no agents available or callback not provided
          : (String? newAgentProfileId) {
              if (newAgentProfileId != currentAgentProfileId && newAgentProfileId != '') {
                onAgentChanged!(newAgentProfileId);
              }
            },
    );
  }
}
