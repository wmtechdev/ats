import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidatesListScreen extends StatelessWidget {
  const AdminCandidatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(title: AppTexts.candidates),
      body: Obx(() => controller.candidates.isEmpty
          ? AppEmptyState(
              message: AppTexts.noCandidatesAvailable,
              icon: Iconsax.profile_circle,
            )
          : ListView.builder(
              padding: AppSpacing.padding(context),
              itemCount: controller.candidates.length,
              itemBuilder: (context, index) {
                final candidate = controller.candidates[index];
                return AppListCard(
                  title: candidate.email,
                  subtitle: '${AppTexts.role}: ${candidate.role}',
                  icon: Iconsax.profile_circle,
                  trailing: Icon(
                    Iconsax.arrow_right_3,
                    size: AppResponsive.iconSize(context),
                    color: AppColors.primary,
                  ),
                  onTap: () {
                    controller.selectCandidate(candidate);
                    Get.toNamed(AppConstants.routeAdminCandidateDetails);
                  },
                );
              },
            )),
    );
  }
}
