import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidatesListScreen extends StatelessWidget {
  const AdminCandidatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: AppTexts.candidates,
      child: Column(
        children: [
          // Search Section
          AppSearchCreateBar(
            searchHint: AppTexts.searchCandidates,
            createButtonText: AppTexts.candidates,
            createButtonIcon: Iconsax.profile_circle,
            onSearchChanged: (value) => controller.setSearchQuery(value),
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
                getPosition: (userId) => controller.getCandidatePosition(userId),
                getStatus: (userId) => controller.getCandidateStatus(userId),
                getAgentName: (userId) => controller.getCandidateAgentName(userId),
                getAssignedAgentProfileId: (userId) => controller.getAssignedAgentProfileId(userId),
                isSuperAdmin: controller.isSuperAdmin,
                availableAgents: agents,
                onAgentChanged: (userId, agentId) => controller.updateCandidateAgent(
                  userId: userId,
                  agentId: agentId,
                ),
                onCandidateTap: (candidate) {
                  controller.selectCandidate(candidate);
                  Get.toNamed(AppConstants.routeAdminCandidateDetails);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
