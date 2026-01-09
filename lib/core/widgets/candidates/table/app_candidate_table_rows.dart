import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/core/widgets/candidates/components/app_candidate_agent_dropdown.dart';
import 'package:ats/core/widgets/candidates/table/app_candidate_table_formatters.dart';
import 'package:ats/core/widgets/common/chips/app_status_chip.dart';

class AppCandidateTableRows {
  AppCandidateTableRows._();

  /// Builds a single data cell with clickable text
  static DataCell buildClickableCell(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ),
        child: InkWell(
          onTap: onTap,
          child: Text(
            text,
            style: AppTextStyles.bodyText(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// Builds a status cell with AppStatusChip
  static DataCell buildStatusCell(
    BuildContext context,
    String status,
    VoidCallback onTap,
  ) {
    final formattedStatus = AppCandidateTableFormatters.formatStatus(status);
    
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ),
        child: InkWell(
          onTap: onTap,
          child: AppStatusChip(
            status: status,
            customText: formattedStatus,
            showIcon: false,
          ),
        ),
      ),
    );
  }

  /// Builds the agent cell (dropdown for super admin, text for others)
  static DataCell buildAgentCell(
    BuildContext context,
    String userId,
    String agentName,
    String? assignedAgentProfileId,
    bool isSuperAdmin,
    List<AdminProfileEntity> availableAgents,
    Future<void> Function(String userId, String? agentId) onAgentChanged,
    VoidCallback onTap,
  ) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ),
        child: isSuperAdmin
            ? AppCandidateAgentDropdown(
                userId: userId,
                currentAgentName: agentName,
                assignedAgentProfileId: assignedAgentProfileId,
                availableAgents: availableAgents,
                onAgentChanged: onAgentChanged,
              )
            : InkWell(
                onTap: onTap,
                child: Text(
                  agentName,
                  style: AppTextStyles.bodyText(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ),
    );
  }

  /// Builds the actions cell with edit and delete buttons
  static DataCell buildActionsCell(
    BuildContext context,
    UserEntity candidate,
    Function(UserEntity)? onEdit,
    Function(UserEntity)? onDelete,
  ) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ),
        child: SizedBox(
          width: 120.0, // Ensure Actions column has minimum width
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(
                    Iconsax.edit,
                    color: AppColors.secondary,
                  ),
                  onPressed: () => onEdit(candidate),
                  tooltip: AppTexts.edit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Iconsax.trash,
                    color: AppColors.error,
                  ),
                  onPressed: () => onDelete(candidate),
                  tooltip: AppTexts.deleteCandidate,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a complete data row for a candidate
  static DataRow buildRow(
    BuildContext context,
    UserEntity candidate, {
    required String name,
    required String email,
    required String company,
    required String position,
    required String profession,
    required String specialties,
    required String status,
    required String agentName,
    required String? assignedAgentProfileId,
    required bool isSuperAdmin,
    required List<AdminProfileEntity> availableAgents,
    required Future<void> Function(String userId, String? agentId) onAgentChanged,
    required VoidCallback onCandidateTap,
    Function(UserEntity)? onCandidateEdit,
    Function(UserEntity)? onCandidateDelete,
  }) {
    return DataRow(
      cells: [
        buildClickableCell(context, name, () => onCandidateTap()),
        buildClickableCell(context, email, () => onCandidateTap()),
        buildClickableCell(context, company, () => onCandidateTap()),
        buildClickableCell(context, position, () => onCandidateTap()),
        buildClickableCell(
          context,
          profession,
          () => onCandidateTap(),
        ),
        buildClickableCell(
          context,
          AppCandidateTableFormatters.formatSpecialties(specialties),
          () => onCandidateTap(),
        ),
        buildStatusCell(
          context,
          status,
          () => onCandidateTap(),
        ),
        buildAgentCell(
          context,
          candidate.userId,
          agentName,
          assignedAgentProfileId,
          isSuperAdmin,
          availableAgents,
          onAgentChanged,
          () => onCandidateTap(),
        ),
        if (isSuperAdmin &&
            (onCandidateEdit != null || onCandidateDelete != null))
          buildActionsCell(
            context,
            candidate,
            onCandidateEdit,
            onCandidateDelete,
          ),
      ],
    );
  }
}
