import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminCandidateDetailsScreen extends StatelessWidget {
  const AdminCandidateDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCandidatesController>();

    return AppAdminLayout(
      title: AppTexts.candidateDetails,
      child: Obx(() {
        final candidate = controller.selectedCandidate.value;
        if (candidate == null) {
          return AppEmptyState(
            message: AppTexts.candidateNotFound,
            icon: Iconsax.profile_circle,
          );
        }

        final profile = controller.selectedCandidateProfile.value;
        final name = profile != null
            ? '${profile.firstName} ${profile.lastName}'.trim()
            : 'N/A';
        final email = candidate.email;
        final workHistory = controller.getWorkHistoryText();
        final documentsCount = controller.getDocumentsCount();
        final applicationsCount = controller.getApplicationsCount();

        final jobTitles = <String, String>{};
        for (var app in controller.candidateApplications) {
          final job = controller.applicationJobs[app.jobId];
          if (job != null) {
            jobTitles[app.jobId] = job.title;
          }
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(dividerColor: AppColors.primary,
                labelStyle: AppTextStyles.bodyText(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
                unselectedLabelStyle: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.primary,
                ),
                tabs: [
                  Tab(text: AppTexts.profile),
                  Tab(text: AppTexts.documents),
                  Tab(text: AppTexts.applications),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    AppCandidateProfileTable(
                      name: name,
                      email: email,
                      workHistory: workHistory,
                      documentsCount: documentsCount,
                      applicationsCount: applicationsCount,
                    ),
                    AppCandidateDocumentsList(
                      documents: controller.candidateDocuments,
                      onStatusUpdate: (candidateDocId, status) {
                        controller.updateDocumentStatus(
                          candidateDocId: candidateDocId,
                          status: status,
                        );
                      },
                      onView: (storageUrl) {
                        // TODO: Implement document viewing functionality
                        Get.snackbar(
                          AppTexts.info,
                          'Document URL: $storageUrl',
                        );
                      },
                    ),
                    AppCandidateApplicationsList(
                      applications: controller.candidateApplications,
                      jobTitles: jobTitles,
                      onStatusUpdate: (applicationId, status) {
                        controller.updateApplicationStatus(
                          applicationId: applicationId,
                          status: status,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
