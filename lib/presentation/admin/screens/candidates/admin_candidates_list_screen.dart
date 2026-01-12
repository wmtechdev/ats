import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidatesListScreen extends StatelessWidget {
  const AdminCandidatesListScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    AdminCandidatesController controller,
    String candidateName,
    String candidateUserId,
    String candidateProfileId,
  ) {
    AppAlertDialog.show(
      title: AppTexts.deleteCandidate,
      subtitle:
          '${AppTexts.deleteCandidateConfirmation} "$candidateName"?\n\n${AppTexts.deleteCandidateWarning}',
      primaryButtonText: AppTexts.delete,
      secondaryButtonText: AppTexts.cancel,
      onPrimaryPressed: () => controller.deleteCandidateById(
        userId: candidateUserId,
        profileId: candidateProfileId,
      ),
      onSecondaryPressed: () {},
      primaryButtonColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: AppTexts.candidates,
      child: Column(
        children: [
          // Search Section
          Obx(
            () => AppSearchCreateBar(
              searchHint: AppTexts.searchCandidates,
              createButtonText: AppTexts.createCandidate,
              createButtonIcon: Iconsax.add,
              onSearchChanged: (value) => controller.setSearchQuery(value),
              onCreatePressed: controller.isSuperAdmin
                  ? () {
                      Get.toNamed(AppConstants.routeAdminCreateCandidate);
                    }
                  : null, // Recruiters can't create candidates
            ),
          ),
          // Filters Section
          Container(
            padding: AppSpacing.padding(context).copyWith(top: 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Access reactive variables at the top level so GetX can track them
                return Obx(() {
                  final selectedAgent = controller.selectedAgentFilter.value;
                  final selectedStatus = controller.selectedStatusFilter.value;
                  final selectedProfession =
                      controller.selectedProfessionFilter.value;
                  final availableAgents = controller.availableAgents.toList();
                  final availableProfessions = controller
                      .getAvailableProfessions();

                  // Get status counts
                  final pendingCount = controller.getStatusCount(
                    AppConstants.documentStatusPending,
                  );
                  final approvedCount = controller.getStatusCount(
                    AppConstants.documentStatusApproved,
                  );
                  final deniedCount = controller.getStatusCount(
                    AppConstants.documentStatusDenied,
                  );

                  // Use wrap layout for smaller screens, row for larger screens
                  if (constraints.maxWidth < 800) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Agent Filter
                            SizedBox(
                              width: constraints.maxWidth > 400
                                  ? (constraints.maxWidth - 16) / 2
                                  : constraints.maxWidth - 16,
                              child: AppDropDownField<String>(
                                value: selectedAgent,
                                labelText: AppTexts.agent,
                                hintText: 'All Agents',
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Agents'),
                                  ),
                                  ...availableAgents.map((agent) {
                                    return DropdownMenuItem<String>(
                                      value: agent.profileId,
                                      child: Text(
                                        agent.name.isNotEmpty
                                            ? agent.name
                                            : 'Unknown Agent',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) =>
                                    controller.setAgentFilter(value),
                              ),
                            ),
                            // Profession Filter
                            SizedBox(
                              width: constraints.maxWidth - 16,
                              child: AppDropDownField<String>(
                                value: selectedProfession,
                                labelText: AppTexts.profession,
                                hintText: 'All Professions',
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Professions'),
                                  ),
                                  ...availableProfessions.map((profession) {
                                    return DropdownMenuItem<String>(
                                      value: profession,
                                      child: Text(
                                        profession,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) =>
                                    controller.setProfessionFilter(value),
                              ),
                            ),
                          ],
                        ),
                        // Status Filter Chips
                        Padding(
                          padding: EdgeInsets.only(
                            top: AppSpacing.vertical(context, 0.02).height!,
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              AppStatusChip(
                                status: AppConstants.documentStatusPending,
                                customText: AppTexts.pending,
                                showIcon: false,
                                count: pendingCount,
                                isSelected:
                                    selectedStatus ==
                                    AppConstants.documentStatusPending,
                                isFilter: true,
                                onTap: () {
                                  if (selectedStatus ==
                                      AppConstants.documentStatusPending) {
                                    controller.setStatusFilter(null);
                                  } else {
                                    controller.setStatusFilter(
                                      AppConstants.documentStatusPending,
                                    );
                                  }
                                },
                              ),
                              AppStatusChip(
                                status: AppConstants.documentStatusApproved,
                                customText: AppTexts.approved,
                                showIcon: false,
                                count: approvedCount,
                                isSelected:
                                    selectedStatus ==
                                    AppConstants.documentStatusApproved,
                                isFilter: true,
                                onTap: () {
                                  if (selectedStatus ==
                                      AppConstants.documentStatusApproved) {
                                    controller.setStatusFilter(null);
                                  } else {
                                    controller.setStatusFilter(
                                      AppConstants.documentStatusApproved,
                                    );
                                  }
                                },
                              ),
                              AppStatusChip(
                                status: AppConstants.documentStatusDenied,
                                customText: AppTexts.denied,
                                showIcon: false,
                                count: deniedCount,
                                isSelected:
                                    selectedStatus ==
                                    AppConstants.documentStatusDenied,
                                isFilter: true,
                                onTap: () {
                                  if (selectedStatus ==
                                      AppConstants.documentStatusDenied) {
                                    controller.setStatusFilter(null);
                                  } else {
                                    controller.setStatusFilter(
                                      AppConstants.documentStatusDenied,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Agent Filter
                            Expanded(
                              child: AppDropDownField<String>(
                                value: selectedAgent,
                                labelText: AppTexts.agent,
                                hintText: 'All Agents',
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Agents'),
                                  ),
                                  ...availableAgents.map((agent) {
                                    return DropdownMenuItem<String>(
                                      value: agent.profileId,
                                      child: Text(
                                        agent.name.isNotEmpty
                                            ? agent.name
                                            : 'Unknown Agent',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) =>
                                    controller.setAgentFilter(value),
                              ),
                            ),
                            AppSpacing.horizontal(context, 0.02),
                            // Profession Filter
                            Expanded(
                              child: AppDropDownField<String>(
                                value: selectedProfession,
                                labelText: AppTexts.profession,
                                hintText: 'All Professions',
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Professions'),
                                  ),
                                  ...availableProfessions.map((profession) {
                                    return DropdownMenuItem<String>(
                                      value: profession,
                                      child: Text(
                                        profession,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) =>
                                    controller.setProfessionFilter(value),
                              ),
                            ),
                          ],
                        ),
                        // Status Filter Chips
                        Padding(
                          padding: EdgeInsets.only(
                            top: AppSpacing.vertical(context, 0.02).height!,
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              AppStatusChip(
                                status: AppConstants.documentStatusPending,
                                customText: AppTexts.pending,
                                showIcon: false,
                                count: pendingCount,
                                isSelected:
                                    selectedStatus ==
                                    AppConstants.documentStatusPending,
                                isFilter: true,
                                onTap: () {
                                  if (selectedStatus ==
                                      AppConstants.documentStatusPending) {
                                    controller.setStatusFilter(null);
                                  } else {
                                    controller.setStatusFilter(
                                      AppConstants.documentStatusPending,
                                    );
                                  }
                                },
                              ),
                              AppStatusChip(
                                status: AppConstants.documentStatusApproved,
                                customText: AppTexts.approved,
                                showIcon: false,
                                count: approvedCount,
                                isSelected:
                                    selectedStatus ==
                                    AppConstants.documentStatusApproved,
                                isFilter: true,
                                onTap: () {
                                  if (selectedStatus ==
                                      AppConstants.documentStatusApproved) {
                                    controller.setStatusFilter(null);
                                  } else {
                                    controller.setStatusFilter(
                                      AppConstants.documentStatusApproved,
                                    );
                                  }
                                },
                              ),
                              AppStatusChip(
                                status: AppConstants.documentStatusDenied,
                                customText: AppTexts.denied,
                                showIcon: false,
                                count: deniedCount,
                                isSelected:
                                    selectedStatus ==
                                    AppConstants.documentStatusDenied,
                                isFilter: true,
                                onTap: () {
                                  if (selectedStatus ==
                                      AppConstants.documentStatusDenied) {
                                    controller.setStatusFilter(null);
                                  } else {
                                    controller.setStatusFilter(
                                      AppConstants.documentStatusDenied,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                });
              },
            ),
          ),
          // Candidates List
          Expanded(
            child: Obx(() {
              // Observe admin profile to rebuild when it loads (for role-based filtering)
              try {
                final authController = Get.find<AdminAuthController>();
                authController.currentAdminProfile.value;
              } catch (e) {
                // AdminAuthController not found, continue
              }

              if (controller.candidates.isEmpty) {
                return AppEmptyState(
                  message: AppTexts.noCandidatesAvailable,
                  icon: Iconsax.profile_circle,
                );
              }

              if (controller.filteredCandidates.isEmpty) {
                return AppEmptyState(
                  message: AppTexts.noCandidatesFound,
                  icon: Iconsax.profile_circle,
                );
              }

              // Observe candidateProfiles and candidateDocumentsMap to rebuild when data loads
              // Access the maps to ensure GetX tracks changes
              for (var candidate in controller.filteredCandidates) {
                controller.candidateProfiles[candidate.userId];
                controller.candidateDocumentsMap[candidate.userId];
              }

              // Observe availableAgents to rebuild when agents load
              final agents = controller.availableAgents.toList();

              return AppCandidatesTable(
                candidates: controller.filteredCandidates,
                getName: (userId) => controller.getCandidateName(userId),
                getCompany: (userId) => controller.getCandidateCompany(userId),
                getPosition: (userId) =>
                    controller.getCandidatePosition(userId),
                getStatus: (userId) => controller.getCandidateStatus(userId),
                getAgentName: (userId) =>
                    controller.getCandidateAgentName(userId),
                getAssignedAgentProfileId: (userId) =>
                    controller.getAssignedAgentProfileId(userId),
                getProfession: (userId) =>
                    controller.getCandidateProfession(userId),
                getSpecialties: (userId) =>
                    controller.getCandidateSpecialties(userId),
                isSuperAdmin: controller.isSuperAdmin,
                availableAgents: agents,
                onAgentChanged: (userId, agentId) => controller
                    .updateCandidateAgent(userId: userId, agentId: agentId),
                onCandidateTap: (candidate) {
                  controller.selectCandidate(candidate);
                  Get.toNamed(AppConstants.routeAdminCandidateDetails);
                },
                onCandidateEdit: controller.isSuperAdmin
                    ? (candidate) {
                        controller.selectCandidate(candidate);
                        Get.toNamed(AppConstants.routeAdminEditCandidate);
                      }
                    : null,
                onCandidateDelete: controller.isSuperAdmin
                    ? (candidate) {
                        // Get candidate name and profile info
                        final candidateName = controller.getCandidateName(
                          candidate.userId,
                        );
                        final profile =
                            controller.candidateProfiles[candidate.userId];
                        final profileId = profile?.profileId ?? '';

                        if (profileId.isEmpty) {
                          AppSnackbar.error(
                            'Unable to delete: Profile ID not found',
                          );
                          return;
                        }

                        _showDeleteConfirmation(
                          context,
                          controller,
                          candidateName,
                          candidate.userId,
                          profileId,
                        );
                      }
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
