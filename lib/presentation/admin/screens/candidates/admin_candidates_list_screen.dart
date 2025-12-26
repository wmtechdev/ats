import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidatesListScreen extends StatelessWidget {
  const AdminCandidatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: AppTexts.candidates,
      child: Obx(() {
        if (controller.candidates.isEmpty) {
          return AppEmptyState(
            message: AppTexts.noCandidatesAvailable,
            icon: Iconsax.profile_circle,
          );
        }

        // Observe candidateProfiles to rebuild when profiles load
        // Access the map to ensure GetX tracks changes
        for (var candidate in controller.candidates) {
          final _ = controller.candidateProfiles[candidate.userId];
        }

        return AppCandidatesTable(
          candidates: controller.candidates,
          getName: (userId) => controller.getCandidateName(userId),
          getCompany: (userId) => controller.getCandidateCompany(userId),
          getPosition: (userId) => controller.getCandidatePosition(userId),
          onCandidateTap: (candidate) {
            controller.selectCandidate(candidate);
            Get.toNamed(AppConstants.routeAdminCandidateDetails);
          },
        );
      }),
    );
  }
}
