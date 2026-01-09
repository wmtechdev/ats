import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_columns.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_rows.dart';

class AppCandidatesTable extends StatelessWidget {
  final List<UserEntity> candidates;
  final String Function(String userId) getName;
  final String Function(String userId) getCompany;
  final String Function(String userId) getPosition;
  final String Function(String userId) getStatus;
  final String Function(String userId) getAgentName;
  final String? Function(String userId) getAssignedAgentProfileId;
  final String Function(String userId) getProfession;
  final String Function(String userId) getSpecialties;
  final Function(UserEntity) onCandidateTap;
  final Function(UserEntity)? onCandidateEdit;
  final Function(UserEntity)? onCandidateDelete;
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
    required this.getProfession,
    required this.getSpecialties,
    required this.onCandidateTap,
    this.onCandidateEdit,
    this.onCandidateDelete,
    required this.isSuperAdmin,
    required this.availableAgents,
    required this.onAgentChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate minimum width needed for all columns
    // Name(200) + Email(280) + Company(200) + Position(200) + Profession(250) + Specialties(280) + Status(150) + Agent(200) + Actions(150) = ~1910
    // Column spacing: 8 gaps * 20 = 160
    // Cell padding: ~100
    // Adding extra padding: ~2200 to ensure all columns are visible, especially Actions column
    const minTableWidth = 2200.0;
    
    final hasActionsColumn = isSuperAdmin && (onCandidateEdit != null || onCandidateDelete != null);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.padding(context).copyWith(
        left: 0,
        right: hasActionsColumn ? 16.0 : 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minTableWidth,
          ),
          child: SizedBox(
            width: minTableWidth,
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
              columns: AppCandidateTableColumns.buildColumns(
                context,
                isSuperAdmin: isSuperAdmin,
                hasEditOrDelete: onCandidateEdit != null || onCandidateDelete != null,
              ),
              rows: candidates.map((candidate) {
                final name = getName(candidate.userId);
                final company = getCompany(candidate.userId);
                final position = getPosition(candidate.userId);
                final profession = getProfession(candidate.userId);
                final specialties = getSpecialties(candidate.userId);
                final status = getStatus(candidate.userId);
                final agentName = getAgentName(candidate.userId);

                return AppCandidateTableRows.buildRow(
                  context,
                  candidate,
                  name: name,
                  email: candidate.email,
                  company: company,
                  position: position,
                  profession: profession,
                  specialties: specialties,
                  status: status,
                  agentName: agentName,
                  assignedAgentProfileId: getAssignedAgentProfileId(candidate.userId),
                  isSuperAdmin: isSuperAdmin,
                  availableAgents: availableAgents,
                  onAgentChanged: onAgentChanged,
                  onCandidateTap: () => onCandidateTap(candidate),
                  onCandidateEdit: onCandidateEdit,
                  onCandidateDelete: onCandidateDelete,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

}
