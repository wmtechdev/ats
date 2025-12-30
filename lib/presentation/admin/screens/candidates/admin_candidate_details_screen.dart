import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/documents/app_document_viewer.dart';

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

        // Observe availableAgents to rebuild when they load
        final availableAgents = controller.availableAgents.toList();

        final profile = controller.selectedCandidateProfile.value;
        final name = profile != null
            ? '${profile.firstName} ${profile.lastName}'.trim()
            : 'N/A';
        final email = candidate.email;
        final workHistory = controller.getWorkHistoryText();
        final documentsCount = controller.getDocumentsCount();
        final applicationsCount = controller.getApplicationsCount();
        final agentName = controller.getCandidateAgentName(candidate.userId);
        final assignedAgentProfileId = controller.getAssignedAgentProfileId(candidate.userId);

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
                      agentName: agentName,
                      isSuperAdmin: controller.isSuperAdmin,
                      availableAgents: availableAgents,
                      assignedAgentProfileId: assignedAgentProfileId,
                      onAgentChanged: controller.isSuperAdmin
                          ? (agentProfileId) => controller.updateCandidateAgent(
                                userId: candidate.userId,
                                agentId: agentProfileId,
                              )
                          : null,
                      userId: candidate.userId,
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
                        // Find the document name for display
                        String? documentName;
                        try {
                          final document = controller.candidateDocuments.firstWhere(
                            (doc) => doc.storageUrl == storageUrl,
                          );
                          documentName = document.title ?? document.documentName;
                        } catch (e) {
                          // Document not found, use default name
                          documentName = null;
                        }
                        AppDocumentViewer.show(
                          documentUrl: storageUrl,
                          documentName: documentName,
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
