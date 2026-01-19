import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_formatters.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/admin/admin_document_actions_button.dart';

class AdminCandidateDetailsScreen extends StatelessWidget {
  const AdminCandidateDetailsScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    AdminCandidatesController controller,
    String candidateName,
  ) {
    AppAlertDialog.show(
      title: AppTexts.deleteCandidate,
      subtitle:
          '${AppTexts.deleteCandidateConfirmation} "$candidateName"?\n\n${AppTexts.deleteCandidateWarning}',
      primaryButtonText: AppTexts.delete,
      secondaryButtonText: AppTexts.cancel,
      onPrimaryPressed: () => controller.deleteCandidate(),
      onSecondaryPressed: () {},
      primaryButtonColor: AppColors.error,
    );
  }

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
        final documentsCount = controller.getDocumentsCount();
        final applicationsCount = controller.getApplicationsCount();
        final agentName = controller.getCandidateAgentName(candidate.userId);
        final assignedAgentProfileId = controller.getAssignedAgentProfileId(
          candidate.userId,
        );

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
              TabBar(
                dividerColor: AppColors.primary,
                labelStyle: AppTextStyles.bodyText(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
                unselectedLabelStyle: AppTextStyles.bodyText(
                  context,
                ).copyWith(color: AppColors.primary),
                tabs: [
                  Tab(text: AppTexts.profile),
                  Tab(text: AppTexts.documents),
                  Tab(text: AppTexts.applications),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Profile Tab with Edit Button at Bottom
                    Column(
                      children: [
                        Expanded(
                          child: AppCandidateProfileTable(
                            profile: profile,
                            fallbackEmail: candidate.email,
                            documentsCount: documentsCount,
                            applicationsCount: applicationsCount,
                            agentName: agentName,
                            isSuperAdmin: controller.isSuperAdmin,
                            availableAgents: availableAgents,
                            assignedAgentProfileId: assignedAgentProfileId,
                            onAgentChanged: controller.isSuperAdmin
                                ? (agentProfileId) =>
                                      controller.updateCandidateAgent(
                                        userId: candidate.userId,
                                        agentId: agentProfileId,
                                      )
                                : null,
                            userId: candidate.userId,
                          ),
                        ),
                        if (controller.isSuperAdmin)
                          Padding(
                            padding: AppSpacing.padding(context),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: AppTexts.edit,
                                    icon: Iconsax.edit,
                                    onPressed: () {
                                      Get.toNamed(
                                        AppConstants.routeAdminEditCandidate,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: AppSpacing.horizontal(
                                    context,
                                    0.02,
                                  ).width,
                                ),
                                Expanded(
                                  child: AppButton(
                                    text: AppTexts.deleteCandidate,
                                    icon: Iconsax.trash,
                                    onPressed: () {
                                      final profileName = profile != null
                                          ? AppCandidateProfileFormatters.getFullName(profile)
                                          : 'N/A';
                                      _showDeleteConfirmation(
                                        context,
                                        controller,
                                        profileName,
                                      );
                                    },
                                    backgroundColor: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    // Documents Tab with FAB
                    Stack(
                      children: [
                        Obx(() {
                          final requestedDocs =
                              controller.candidateRequestedDocumentTypes.toList();
                          final allCandidateDocs =
                              controller.candidateDocuments.toList();
                          
                          // Filter out documents that are from requested document types
                          // to avoid showing them twice (once in requested section, once in regular section)
                          final requestedDocTypeIds = requestedDocs
                              .map((docType) => docType.docTypeId)
                              .toSet();
                          final regularDocs = allCandidateDocs
                              .where((doc) => !requestedDocTypeIds.contains(doc.docTypeId))
                              .toList();

                          return CustomScrollView(
                            slivers: [
                              // Requested Documents Section
                              if (requestedDocs.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: AppRequestedDocumentsList(
                                    requestedDocuments: requestedDocs,
                                    candidateDocuments: allCandidateDocs,
                                    onRevoke: (docTypeId) {
                                      controller.revokeDocumentRequest(docTypeId);
                                    },
                                    onView: (storageUrl) {
                                      // Find the document name for display
                                      String? documentName;
                                      try {
                                        final document = allCandidateDocs.firstWhere(
                                          (doc) => doc.storageUrl == storageUrl,
                                        );
                                        documentName =
                                            document.title ??
                                            AppFileValidator.extractOriginalFileName(
                                              document.documentName,
                                            );
                                      } catch (e) {
                                        // Document not found, use default name
                                        documentName = null;
                                      }
                                      AppDocumentViewer.show(
                                        documentUrl: storageUrl,
                                        documentName: documentName,
                                      );
                                    },
                                    onStatusUpdate: (candidateDocId, status) {
                                      controller.updateDocumentStatus(
                                        candidateDocId: candidateDocId,
                                        status: status,
                                      );
                                    },
                                    onDeny: (candidateDocId, status, denialReason) {
                                      controller.denyDocumentWithEmail(
                                        candidateDocId: candidateDocId,
                                        status: status,
                                        denialReason: denialReason,
                                      );
                                    },
                                  ),
                                ),
                              // Regular Documents List (excluding requested documents)
                              if (regularDocs.isEmpty && requestedDocs.isEmpty)
                                SliverFillRemaining(
                                  child: AppEmptyState(
                                    message: AppTexts.noDocumentsFound,
                                    icon: Iconsax.document_text,
                                  ),
                                )
                              else if (regularDocs.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: AppCandidateDocumentsList(
                                    documents: regularDocs,
                                    onStatusUpdate: (candidateDocId, status) {
                                      controller.updateDocumentStatus(
                                        candidateDocId: candidateDocId,
                                        status: status,
                                      );
                                    },
                                    onDeny: (candidateDocId, status, denialReason) {
                                      controller.denyDocumentWithEmail(
                                        candidateDocId: candidateDocId,
                                        status: status,
                                        denialReason: denialReason,
                                      );
                                    },
                                    onView: (storageUrl) {
                                      // Find the document name for display
                                      String? documentName;
                                      try {
                                        final document = allCandidateDocs.firstWhere(
                                          (doc) => doc.storageUrl == storageUrl,
                                        );
                                        documentName =
                                            document.title ??
                                            AppFileValidator.extractOriginalFileName(
                                              document.documentName,
                                            );
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
                                ),
                            ],
                          );
                        }),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: AdminDocumentActionsButton(),
                        ),
                      ],
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
