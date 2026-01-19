import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/data/repositories/document_repository_impl.dart';
import 'package:ats/data/models/document_type_model.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/usecases/application/update_application_status_usecase.dart';
import 'package:ats/domain/usecases/document/update_document_status_usecase.dart';
import 'package:ats/domain/usecases/email/send_document_denial_email_usecase.dart';
import 'package:ats/domain/usecases/email/send_document_request_email_usecase.dart';
import 'package:ats/domain/usecases/email/send_document_request_revocation_email_usecase.dart';
import 'package:ats/domain/usecases/email/send_admin_document_upload_email_usecase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ats/domain/usecases/admin/delete_candidate_usecase.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/candidates/profile/app_candidate_profile_formatters.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';

class AdminCandidatesController extends GetxController {
  final AdminRepository adminRepository;
  final ApplicationRepository applicationRepository;
  final DocumentRepository documentRepository;
  final CandidateProfileRepository candidateProfileRepository;
  final JobRepository jobRepository;

  AdminCandidatesController(
    this.adminRepository,
    this.applicationRepository,
    this.documentRepository,
    this.candidateProfileRepository,
    this.jobRepository,
  );

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final candidates = <UserEntity>[].obs;
  final filteredCandidates = <UserEntity>[].obs;
  final searchQuery = ''.obs;
  final candidateProfiles = <String, CandidateProfileEntity?>{}.obs;
  final candidateDocumentsMap = <String, List<CandidateDocumentEntity>>{}.obs;
  final selectedCandidate = Rxn<UserEntity>();
  final selectedCandidateProfile = Rxn<CandidateProfileEntity>();
  final candidateApplications = <ApplicationEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;
  final candidateRequestedDocumentTypes = <DocumentTypeEntity>[].obs;
  final applicationJobs = <String, JobEntity?>{}.obs;
  final availableAgents = <AdminProfileEntity>[].obs;
  final candidateProfileStreams =
      <String, StreamSubscription<CandidateProfileEntity?>>{};

  // File selection for admin document upload
  final selectedFile = Rxn<PlatformFile>();
  final selectedFileName = ''.obs;
  final selectedFileSize = ''.obs;
  final uploadProgress = 0.0.obs;
  final isUploading = false.obs;

  // Filter state
  final selectedAgentFilter = Rxn<String>(); // profileId
  final selectedStatusFilter = Rxn<String>();
  final selectedProfessionFilter = Rxn<String>();

  late final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;
  late final UpdateDocumentStatusUseCase updateDocumentStatusUseCase;
  late final SendDocumentDenialEmailUseCase sendDocumentDenialEmailUseCase;
  late final SendDocumentRequestEmailUseCase sendDocumentRequestEmailUseCase;
  late final SendDocumentRequestRevocationEmailUseCase
      sendDocumentRequestRevocationEmailUseCase;
  late final SendAdminDocumentUploadEmailUseCase
      sendAdminDocumentUploadEmailUseCase;
  late final DeleteCandidateUseCase deleteCandidateUseCase;

  // Stream subscriptions
  StreamSubscription<List<ApplicationEntity>>? _applicationsSubscription;
  StreamSubscription<List<CandidateDocumentEntity>>? _documentsSubscription;
  StreamSubscription<CandidateProfileEntity?>? _profileSubscription;
  final Map<String, StreamSubscription<List<CandidateDocumentEntity>>>
  _candidateDocumentsSubscriptions = {};

  @override
  void onInit() {
    super.onInit();
    // Initialize use cases after repositories are registered
    updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(
      Get.find<ApplicationRepository>(),
    );
    updateDocumentStatusUseCase = UpdateDocumentStatusUseCase(
      Get.find<DocumentRepository>(),
    );
    sendDocumentDenialEmailUseCase = SendDocumentDenialEmailUseCase(
      Get.find<EmailRepository>(),
    );
    sendDocumentRequestEmailUseCase = SendDocumentRequestEmailUseCase(
      Get.find<EmailRepository>(),
    );
    sendDocumentRequestRevocationEmailUseCase =
        SendDocumentRequestRevocationEmailUseCase(
      Get.find<EmailRepository>(),
    );
    sendAdminDocumentUploadEmailUseCase = SendAdminDocumentUploadEmailUseCase(
      Get.find<EmailRepository>(),
    );
    deleteCandidateUseCase = DeleteCandidateUseCase(adminRepository);
    loadCandidates();
    loadAvailableAgents();

    // Observe admin profile changes to re-apply filters when profile loads
    try {
      final authController = Get.find<AdminAuthController>();
      ever(authController.currentAdminProfile, (_) {
        // Re-apply filters when admin profile loads/changes
        _applyFilters();
      });
    } catch (e) {
      // AdminAuthController not found, continue
    }
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _applicationsSubscription?.cancel();
    _documentsSubscription?.cancel();
    _profileSubscription?.cancel();
    for (var subscription in _candidateDocumentsSubscriptions.values) {
      subscription.cancel();
    }
    for (var subscription in candidateProfileStreams.values) {
      subscription.cancel();
    }
    _candidateDocumentsSubscriptions.clear();
    candidateProfileStreams.clear();
    // Clear file selection
    clearSelectedFile();
    super.onClose();
  }

  void loadCandidates() {
    isLoading.value = true;
    errorMessage.value = '';

    adminRepository
        .getCandidates()
        .then((result) {
          result.fold(
            (failure) {
              errorMessage.value = failure.message;
              isLoading.value = false;
            },
            (candidatesList) {
              candidates.value = candidatesList;
              isLoading.value = false;
              _applyFilters();

              // Load profiles and documents for all candidates
              for (var candidate in candidatesList) {
                loadCandidateProfile(candidate.userId);
                loadCandidateDocumentsForList(candidate.userId);
              }
            },
          );
        })
        .catchError((error) {
          errorMessage.value = error.toString();
          isLoading.value = false;
        });
  }

  void loadCandidateProfile(String userId) {
    // Cancel existing subscription if any
    candidateProfileStreams[userId]?.cancel();

    // Use stream to get profile with profileId
    final subscription = candidateProfileRepository
        .streamProfile(userId)
        .listen(
          (profile) {
            if (profile != null) {
              candidateProfiles[userId] = profile;
              candidateProfiles.refresh(); // Trigger reactivity
              _applyFilters(); // Re-apply filters when profile loads
            }
          },
          onError: (error) {
            // Silently handle errors
          },
        );

    candidateProfileStreams[userId] = subscription;
  }

  void selectCandidate(UserEntity candidate) {
    selectedCandidate.value = candidate;
    loadCandidateProfileStream(candidate.userId);
    loadCandidateApplications(candidate.userId);
    loadCandidateDocuments(candidate.userId);
    loadCandidateRequestedDocumentTypes(candidate.userId);
  }

  void loadCandidateProfileStream(String userId) {
    _profileSubscription?.cancel();
    _profileSubscription = candidateProfileRepository
        .streamProfile(userId)
        .listen(
          (profile) {
            selectedCandidateProfile.value = profile;
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );
  }

  void loadCandidateApplications(String candidateId) {
    _applicationsSubscription
        ?.cancel(); // Cancel previous subscription if exists
    _applicationsSubscription = applicationRepository
        .streamApplications(candidateId: candidateId)
        .listen(
          (apps) {
            candidateApplications.value = apps;
            // Load job details for each application
            for (var app in apps) {
              loadJobDetails(app.jobId);
            }
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );
  }

  void loadJobDetails(String jobId) {
    if (applicationJobs.containsKey(jobId)) return;
    jobRepository.getJob(jobId).then((result) {
      result.fold(
        (failure) => null, // Silently handle errors
        (job) => applicationJobs[jobId] = job,
      );
    });
  }

  void loadCandidateDocuments(String candidateId) {
    _documentsSubscription?.cancel(); // Cancel previous subscription if exists
    _documentsSubscription = documentRepository
        .streamCandidateDocuments(candidateId)
        .listen(
          (docs) {
            candidateDocuments.value = docs;
            // Reload requested document types to update completion status
            loadCandidateRequestedDocumentTypes(candidateId);
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );
  }

  /// Load candidate-specific requested document types
  void loadCandidateRequestedDocumentTypes(String candidateId) async {
    try {
      final repositoryImpl = documentRepository as DocumentRepositoryImpl;
      final docTypesData =
          await repositoryImpl.getCandidateSpecificDocumentTypes(candidateId);
      final docTypes = docTypesData.map((data) {
        return DocumentTypeModel(
          docTypeId: data['docTypeId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          isRequired: data['isRequired'] ?? false,
          isCandidateSpecific: data['isCandidateSpecific'] ?? true,
          requestedForCandidateId: data['requestedForCandidateId'] as String?,
          requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
        ).toEntity();
      }).toList();
      candidateRequestedDocumentTypes.value = docTypes;
    } catch (e) {
      candidateRequestedDocumentTypes.value = [];
    }
  }

  /// Check if a requested document has been uploaded by the candidate
  bool isRequestedDocumentUploaded(String docTypeId) {
    return candidateDocuments.any((doc) => doc.docTypeId == docTypeId);
  }

  /// Get the uploaded document for a requested document type
  CandidateDocumentEntity? getUploadedRequestedDocument(String docTypeId) {
    try {
      return candidateDocuments.firstWhere((doc) => doc.docTypeId == docTypeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateDocumentStatus({
    required String candidateDocId,
    required String status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateDocumentStatusUseCase(
      candidateDocId: candidateDocId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (document) {
        isLoading.value = false;
        AppSnackbar.success('Document status updated');
      },
    );
  }

  /// Denies a document and sends email notification to the candidate
  /// Blocks the deny operation if email sending fails
  Future<void> denyDocumentWithEmail({
    required String candidateDocId,
    required String status,
    String? denialReason,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Get candidate and document information
    final candidate = selectedCandidate.value;
    final profile = selectedCandidateProfile.value;

    if (candidate == null) {
      errorMessage.value = 'Candidate not selected';
      isLoading.value = false;
      AppSnackbar.error('Candidate not selected');
      return;
    }

    // Find the document
    final document = candidateDocuments.firstWhere(
      (doc) => doc.candidateDocId == candidateDocId,
      orElse: () => candidateDocuments.first, // Fallback, but should not happen
    );

    final documentName =
        document.title ??
        AppFileValidator.extractOriginalFileName(document.documentName);
    final candidateEmail = candidate.email;
    final candidateName = profile != null
        ? AppCandidateProfileFormatters.getFullName(profile)
        : candidateEmail;

    // Step 1: Send email first (as per requirement: block if email fails)
    final emailResult = await sendDocumentDenialEmailUseCase(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: documentName,
      denialReason: denialReason,
    );

    emailResult.fold(
      (failure) {
        // Email failed - block the deny operation
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('${AppTexts.emailFailed}: ${failure.message}');
      },
      (_) {
        // Email sent successfully - proceed with status update
        _updateDocumentStatusAfterEmail(candidateDocId, status);
      },
    );
  }

  /// Requests a document for the selected candidate
  /// Creates a candidate-specific document type and sends email notification
  /// If email fails, document type is not created
  Future<void> requestDocumentForCandidate({
    required String name,
    required String description,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final candidate = selectedCandidate.value;
    final profile = selectedCandidateProfile.value;

    if (candidate == null) {
      errorMessage.value = 'Candidate not selected';
      isLoading.value = false;
      AppSnackbar.error('Candidate not selected');
      return;
    }

    final candidateId = candidate.userId;
    final candidateEmail = candidate.email;
    final candidateName = profile != null
        ? AppCandidateProfileFormatters.getFullName(profile)
        : candidateEmail;

    // Check if the same document type already exists for this candidate
    final repositoryImpl = documentRepository as DocumentRepositoryImpl;
    try {
      final existingDocTypes =
          await repositoryImpl.getCandidateSpecificDocumentTypes(candidateId);
      final duplicateExists = existingDocTypes.any((doc) =>
          doc['name']?.toString().toLowerCase() == name.toLowerCase());

      if (duplicateExists) {
        // Show warning but allow proceeding
        AppSnackbar.info(
            'A document with the same name already exists for this candidate. Creating anyway...');
      }
    } catch (e) {
      // Continue if check fails
    }

    // Step 1: Send email first (as per requirement: don't create if email fails)
    final emailResult = await sendDocumentRequestEmailUseCase(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: name,
      documentDescription: description,
    );

    emailResult.fold(
      (failure) {
        // Email failed - don't create document type
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to send email: ${failure.message}');
      },
      (_) {
        // Email sent successfully - proceed with document type creation
        _createDocumentTypeAfterEmail(candidateId, name, description);
      },
    );
  }

  /// Creates document type after email is sent successfully
  void _createDocumentTypeAfterEmail(
    String candidateId,
    String name,
    String description,
  ) async {
    final repositoryImpl = documentRepository as DocumentRepositoryImpl;
    final result = await repositoryImpl.createCandidateSpecificDocumentType(
      name: name,
      description: description,
      candidateId: candidateId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to create document type: ${failure.message}');
      },
      (docType) {
        isLoading.value = false;
        AppSnackbar.success(AppTexts.documentRequested);
        // Reload requested document types
        loadCandidateRequestedDocumentTypes(candidateId);
        // Navigate back to candidate details screen (Documents tab)
        Get.offNamedUntil(
          AppConstants.routeAdminCandidateDetails,
          (route) =>
              route.settings.name == AppConstants.routeAdminCandidateDetails,
        );
      },
    );
  }

  /// Revokes a requested document for the selected candidate
  /// Deletes the document type and sends email notification
  Future<void> revokeDocumentRequest(String docTypeId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final candidate = selectedCandidate.value;
    final profile = selectedCandidateProfile.value;

    if (candidate == null) {
      errorMessage.value = 'Candidate not selected';
      isLoading.value = false;
      AppSnackbar.error('Candidate not selected');
      return;
    }

    // Get document type from requested documents list
    final docType = candidateRequestedDocumentTypes.firstWhere(
      (dt) => dt.docTypeId == docTypeId,
      orElse: () => candidateRequestedDocumentTypes.first,
    );

    if (docType.docTypeId != docTypeId) {
      errorMessage.value = 'Document type not found';
      isLoading.value = false;
      AppSnackbar.error('Document type not found');
      return;
    }

    final candidateEmail = candidate.email;
    final candidateName = profile != null
        ? AppCandidateProfileFormatters.getFullName(profile)
        : candidateEmail;

    // Step 1: Delete document type
    final deleteResult = await documentRepository.deleteDocumentType(docTypeId);

    deleteResult.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to delete document type: ${failure.message}');
      },
      (_) {
        // Step 2: Send email notification
        _sendRevocationEmailAfterDelete(
          candidateEmail: candidateEmail,
          candidateName: candidateName,
          documentName: docType.name,
        );
      },
    );
  }

  /// Sends revocation email after document type is deleted
  void _sendRevocationEmailAfterDelete({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) async {
    final emailResult = await sendDocumentRequestRevocationEmailUseCase(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: documentName,
    );

    emailResult.fold(
      (failure) {
        // Email failed but document is already deleted
        isLoading.value = false;
        AppSnackbar.warning(
            'Document request revoked, but failed to send email: ${failure.message}');
      },
      (_) {
        isLoading.value = false;
        AppSnackbar.success(AppTexts.documentRequestRevoked);
        // Reload requested document types
        final currentCandidate = selectedCandidate.value;
        if (currentCandidate != null) {
          loadCandidateRequestedDocumentTypes(currentCandidate.userId);
        }
      },
    );
  }

  /// Updates document status after email is sent successfully
  void _updateDocumentStatusAfterEmail(
    String candidateDocId,
    String status,
  ) async {
    final result = await updateDocumentStatusUseCase(
      candidateDocId: candidateDocId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error(
          'Failed to update document status: ${failure.message}',
        );
      },
      (document) {
        isLoading.value = false;
        AppSnackbar.success(AppTexts.documentDenied);
        AppSnackbar.success(AppTexts.emailSent);
      },
    );
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await updateApplicationStatusUseCase(
        applicationId: applicationId,
        status: status,
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          isLoading.value = false;
          AppSnackbar.error(failure.message);
        },
        (application) {
          isLoading.value = false;
          AppSnackbar.success('Application status updated');
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to update application status: $e';
      isLoading.value = false;
      AppSnackbar.error('Failed to update application status: $e');
    }
  }

  // Helper methods
  String getCandidateName(String userId) {
    final profile = candidateProfiles[userId];
    if (profile == null) return 'N/A';
    return AppCandidateProfileFormatters.getFullName(profile);
  }

  String getCandidateCompany(String userId) {
    final profile = candidateProfiles[userId];
    if (profile?.workHistory == null || profile!.workHistory!.isEmpty) {
      return 'N/A';
    }
    // Get the most recent work history entry
    final latestWork = profile.workHistory!.last;
    return latestWork['company']?.toString() ?? 'N/A';
  }

  String getCandidatePosition(String userId) {
    final profile = candidateProfiles[userId];
    if (profile?.workHistory == null || profile!.workHistory!.isEmpty) {
      return 'N/A';
    }
    // Get the most recent work history entry
    final latestWork = profile.workHistory!.last;
    return latestWork['position']?.toString() ?? 'N/A';
  }

  String getCandidateProfession(String userId) {
    final profile = candidateProfiles[userId];
    return profile?.profession ?? 'N/A';
  }

  String getCandidateSpecialties(String userId) {
    final profile = candidateProfiles[userId];
    return profile?.specialties ?? 'N/A';
  }

  void loadCandidateDocumentsForList(String candidateId) {
    // Cancel existing subscription if any
    _candidateDocumentsSubscriptions[candidateId]?.cancel();

    // Create new subscription
    final subscription = documentRepository
        .streamCandidateDocuments(candidateId)
        .listen(
          (docs) {
            candidateDocumentsMap[candidateId] = docs;
            candidateDocumentsMap.refresh(); // Trigger reactivity
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );

    _candidateDocumentsSubscriptions[candidateId] = subscription;
  }

  String getCandidateStatus(String userId) {
    final documents = candidateDocumentsMap[userId] ?? [];

    if (documents.isEmpty) {
      return AppConstants.documentStatusPending; // No documents means pending
    }

    // Check if any document is rejected/denied
    final hasRejected = documents.any(
      (doc) => doc.status == AppConstants.documentStatusDenied,
    );
    if (hasRejected) {
      return AppConstants.documentStatusDenied;
    }

    // Check if any document is pending
    final hasPending = documents.any(
      (doc) => doc.status == AppConstants.documentStatusPending,
    );
    if (hasPending) {
      return AppConstants.documentStatusPending;
    }

    // Check if all documents are approved
    final allApproved = documents.every(
      (doc) => doc.status == AppConstants.documentStatusApproved,
    );
    if (allApproved) {
      return AppConstants.documentStatusApproved;
    }

    // Default to pending if status is unclear
    return AppConstants.documentStatusPending;
  }

  int getDocumentsCount() {
    return candidateDocuments.length;
  }

  int getApplicationsCount() {
    return candidateApplications.length;
  }

  String getWorkHistoryText() {
    final profile = selectedCandidateProfile.value;
    if (profile?.workHistory == null || profile!.workHistory!.isEmpty) {
      return 'No work history';
    }
    return profile.workHistory!
        .map(
          (work) =>
              '${work['company'] ?? 'N/A'} - ${work['position'] ?? 'N/A'}',
        )
        .join('\n');
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setAgentFilter(String? agentProfileId) {
    selectedAgentFilter.value = agentProfileId;
    _applyFilters();
  }

  void setStatusFilter(String? status) {
    selectedStatusFilter.value = status;
    _applyFilters();
  }

  void setProfessionFilter(String? profession) {
    selectedProfessionFilter.value = profession;
    _applyFilters();
  }

  // Get unique professions from all candidate profiles
  List<String> getAvailableProfessions() {
    final professions = <String>{};
    for (var profile in candidateProfiles.values) {
      if (profile?.profession != null && profile!.profession!.isNotEmpty) {
        professions.add(profile.profession!);
      }
    }
    return professions.toList()..sort();
  }

  // Get count of candidates by status
  int getStatusCount(String status) {
    return candidates.where((candidate) {
      final candidateStatus = getCandidateStatus(candidate.userId);
      return candidateStatus == status;
    }).length;
  }

  void _applyFilters() {
    var filtered = List<UserEntity>.from(candidates);

    // Apply role-based filtering
    // Recruiters only see candidates assigned to them, admins see all candidates
    if (!isSuperAdmin) {
      // User is a recruiter - only show candidates assigned to this recruiter
      final recruiterProfileId = currentUserProfileId;
      if (recruiterProfileId != null && recruiterProfileId.isNotEmpty) {
        filtered = filtered.where((candidate) {
          final profile = candidateProfiles[candidate.userId];
          // Show candidate if assignedAgentId matches recruiter's profileId
          return profile?.assignedAgentId == recruiterProfileId;
        }).toList();
      } else {
        // If profileId not available, show no candidates for recruiter
        filtered = [];
      }
    }
    // If super_admin, show all candidates (no filtering by agent)

    // Apply agent filter
    if (selectedAgentFilter.value != null &&
        selectedAgentFilter.value!.isNotEmpty) {
      filtered = filtered.where((candidate) {
        final profile = candidateProfiles[candidate.userId];
        return profile?.assignedAgentId == selectedAgentFilter.value;
      }).toList();
    }

    // Apply status filter
    if (selectedStatusFilter.value != null &&
        selectedStatusFilter.value!.isNotEmpty) {
      filtered = filtered.where((candidate) {
        final status = getCandidateStatus(candidate.userId);
        return status == selectedStatusFilter.value;
      }).toList();
    }

    // Apply profession filter
    if (selectedProfessionFilter.value != null &&
        selectedProfessionFilter.value!.isNotEmpty) {
      filtered = filtered.where((candidate) {
        final profession = getCandidateProfession(candidate.userId);
        return profession == selectedProfessionFilter.value;
      }).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((candidate) {
        final profile = candidateProfiles[candidate.userId];

        // Search by email
        if (candidate.email.toLowerCase().contains(query)) {
          return true;
        }

        // Search by name
        final name = getCandidateName(candidate.userId).toLowerCase();
        if (name.contains(query)) {
          return true;
        }

        // Search by company
        final company = getCandidateCompany(candidate.userId).toLowerCase();
        if (company.contains(query)) {
          return true;
        }

        // Search by position
        final position = getCandidatePosition(candidate.userId).toLowerCase();
        if (position.contains(query)) {
          return true;
        }

        // Search by profession
        final profession = getCandidateProfession(
          candidate.userId,
        ).toLowerCase();
        if (profession.contains(query)) {
          return true;
        }

        // Search by specialties
        final specialties = getCandidateSpecialties(
          candidate.userId,
        ).toLowerCase();
        if (specialties.contains(query)) {
          return true;
        }

        // Search by agent name
        final agentName = getCandidateAgentName(candidate.userId).toLowerCase();
        if (agentName.contains(query)) {
          return true;
        }

        // Search by status
        final status = getCandidateStatus(candidate.userId).toLowerCase();
        if (status.contains(query)) {
          return true;
        }

        // Search by address fields
        if (profile != null) {
          if (profile.address1 != null &&
              profile.address1!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.address2 != null &&
              profile.address2!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.city != null &&
              profile.city!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.state != null &&
              profile.state!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.zip != null &&
              profile.zip!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.ssn != null &&
              profile.ssn!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.npi != null &&
              profile.npi!.toLowerCase().contains(query)) {
            return true;
          }
          if (profile.licensureState != null &&
              profile.licensureState!.toLowerCase().contains(query)) {
            return true;
          }
        }

        // Search in phones
        if (profile?.phones != null) {
          for (var phone in profile!.phones!) {
            final number = phone['number']?.toString().toLowerCase() ?? '';
            if (number.contains(query)) {
              return true;
            }
          }
        }

        // Search in work history
        if (profile?.workHistory != null) {
          for (var work in profile!.workHistory!) {
            final company = work['company']?.toString().toLowerCase() ?? '';
            final position = work['position']?.toString().toLowerCase() ?? '';
            final description =
                work['description']?.toString().toLowerCase() ?? '';
            if (company.contains(query) ||
                position.contains(query) ||
                description.contains(query)) {
              return true;
            }
          }
        }

        // Search in education
        if (profile?.education != null) {
          for (var edu in profile!.education!) {
            final institution =
                edu['institutionName']?.toString().toLowerCase() ?? '';
            final degree = edu['degree']?.toString().toLowerCase() ?? '';
            if (institution.contains(query) || degree.contains(query)) {
              return true;
            }
          }
        }

        // Search in certifications
        if (profile?.certifications != null) {
          for (var cert in profile!.certifications!) {
            final name = cert['name']?.toString().toLowerCase() ?? '';
            if (name.contains(query)) {
              return true;
            }
          }
        }

        return false;
      }).toList();
    }

    filteredCandidates.value = filtered;
  }

  // Agent assignment methods
  /// Loads all admin profiles (both super_admin and recruiter) from Firestore
  /// These profiles are used to populate the agent dropdown in the candidates table.
  /// Source: adminProfilesCollection in Firestore
  /// Each profile contains: userId, name (firstName + lastName), accessLevel, email
  void loadAvailableAgents() {
    adminRepository
        .getAllAdminProfiles()
        .then((result) {
          result.fold(
            (failure) {
              AppSnackbar.error('Failed to load agents: ${failure.message}');
            },
            (profiles) {
              availableAgents.value = profiles;
            },
          );
        })
        .catchError((error) {
          AppSnackbar.error('Failed to load agents: $error');
        });
  }

  /// Get list of available agent names (for debugging/info purposes)
  List<String> getAvailableAgentNames() {
    return availableAgents.map((agent) => agent.name).toList();
  }

  bool get isSuperAdmin {
    try {
      final authController = Get.find<AdminAuthController>();
      return authController.isSuperAdmin;
    } catch (e) {
      return false;
    }
  }

  /// Get current user's admin profile ID (document ID from adminProfiles collection)
  String? get currentUserProfileId {
    try {
      final authController = Get.find<AdminAuthController>();
      return authController.currentAdminProfile.value?.profileId;
    } catch (e) {
      return null;
    }
  }

  /// Get agent name by admin profile document ID (profileId)
  /// assignedAgentId stores the profileId from adminProfiles collection
  String? getAgentName(String? agentProfileId) {
    if (agentProfileId == null || agentProfileId.isEmpty) return null;
    try {
      final agent = availableAgents.firstWhere(
        (a) => a.profileId == agentProfileId,
        orElse: () => AdminProfileEntity(
          profileId: '',
          userId: '',
          name: '',
          accessLevel: '',
          email: '',
        ),
      );
      return agent.name.isNotEmpty ? agent.name : null;
    } catch (e) {
      return null;
    }
  }

  String getCandidateAgentName(String userId) {
    final profile = candidateProfiles[userId];
    if (profile?.assignedAgentId == null || profile!.assignedAgentId!.isEmpty) {
      return 'N/A';
    }
    return getAgentName(profile.assignedAgentId) ?? 'N/A';
  }

  /// Get the assigned agent profile ID (document ID from adminProfiles collection) for a candidate
  String? getAssignedAgentProfileId(String userId) {
    final profile = candidateProfiles[userId];
    if (profile?.assignedAgentId == null || profile!.assignedAgentId!.isEmpty) {
      return null;
    }
    return profile.assignedAgentId;
  }

  /// Update the assigned agent for a candidate
  /// agentId should be the profileId (document ID) from adminProfiles collection
  Future<void> updateCandidateAgent({
    required String userId,
    required String?
    agentId, // This is the profileId from adminProfiles collection
  }) async {
    final profile = candidateProfiles[userId];
    if (profile == null) {
      AppSnackbar.error('Candidate profile not found');
      return;
    }

    // Get profileId - use from profile if available, otherwise try to get it
    String profileId = profile.profileId;
    if (profileId.isEmpty) {
      // Try to get profileId from stream data
      // For now, we'll need to query it or use a different approach
      AppSnackbar.error('Unable to update agent: Profile ID not found');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    // Convert null to empty string to represent unassign
    final agentIdToUpdate = agentId ?? '';

    final result = await candidateProfileRepository.updateProfile(
      profileId: profileId,
      assignedAgentId: agentIdToUpdate,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to update agent: ${failure.message}');
      },
      (updatedProfile) {
        candidateProfiles[userId] = updatedProfile;
        candidateProfiles.refresh();
        isLoading.value = false;
        AppSnackbar.success('Agent updated successfully');
      },
    );
  }

  /// Update candidate profile (admin can edit all fields)
  Future<void> updateCandidateProfile({
    required String firstName,
    required String lastName,
    String? middleName,
    String? email,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zip,
    String? ssn,
    List<Map<String, dynamic>>? phones,
    String? profession,
    String? specialties,
    String? liabilityAction,
    String? licenseAction,
    String? previouslyTraveled,
    String? terminatedFromAssignment,
    String? licensureState,
    String? npi,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? certifications,
    List<Map<String, dynamic>>? workHistory,
  }) async {
    final profile = selectedCandidateProfile.value;
    if (profile == null) {
      AppSnackbar.error('Candidate profile not found');
      return;
    }

    final profileId = profile.profileId;
    if (profileId.isEmpty) {
      AppSnackbar.error('Unable to update: Profile ID not found');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await candidateProfileRepository.updateProfile(
      profileId: profileId,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      email: email,
      address1: address1,
      address2: address2,
      city: city,
      state: state,
      zip: zip,
      ssn: ssn,
      phones: phones,
      profession: profession,
      specialties: specialties,
      liabilityAction: liabilityAction,
      licenseAction: licenseAction,
      previouslyTraveled: previouslyTraveled,
      terminatedFromAssignment: terminatedFromAssignment,
      licensureState: licensureState,
      npi: npi,
      education: education,
      certifications: certifications,
      workHistory: workHistory,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to update candidate: ${failure.message}');
      },
      (updatedProfile) {
        selectedCandidateProfile.value = updatedProfile;
        candidateProfiles[profile.userId] = updatedProfile;
        candidateProfiles.refresh();
        isLoading.value = false;
        AppSnackbar.success('Candidate updated successfully');
        // Navigate to candidate details screen
        Get.offNamed(AppConstants.routeAdminCandidateDetails);
      },
    );
  }

  /// Delete candidate and all associated data (from details screen)
  Future<void> deleteCandidate() async {
    final candidate = selectedCandidate.value;
    if (candidate == null) {
      AppSnackbar.error('Candidate not selected');
      return;
    }

    final profile = selectedCandidateProfile.value;
    if (profile == null) {
      AppSnackbar.error('Candidate profile not found');
      return;
    }

    final profileId = profile.profileId;
    if (profileId.isEmpty) {
      AppSnackbar.error('Unable to delete: Profile ID not found');
      return;
    }

    await deleteCandidateById(userId: candidate.userId, profileId: profileId);
  }

  /// Delete candidate by ID (can be called from list or details screen)
  Future<void> deleteCandidateById({
    required String userId,
    required String profileId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await deleteCandidateUseCase(
      userId: userId,
      profileId: profileId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to delete candidate: ${failure.message}');
      },
      (_) {
        isLoading.value = false;
        AppSnackbar.success('Candidate deleted successfully');

        // Clear selected candidate if it's the one being deleted
        if (selectedCandidate.value?.userId == userId) {
          selectedCandidate.value = null;
          selectedCandidateProfile.value = null;
        }

        // Remove from local lists
        candidates.removeWhere((c) => c.userId == userId);
        filteredCandidates.removeWhere((c) => c.userId == userId);
        candidateProfiles.remove(userId);
        candidateDocumentsMap.remove(userId);

        // Cancel any active streams for this candidate
        candidateProfileStreams[userId]?.cancel();
        candidateProfileStreams.remove(userId);
        _candidateDocumentsSubscriptions[userId]?.cancel();
        _candidateDocumentsSubscriptions.remove(userId);

        // Reload candidates list to ensure consistency
        loadCandidates();

        // If we're on details screen, navigate back
        if (Get.currentRoute == AppConstants.routeAdminCandidateDetails) {
          Get.offNamed(AppConstants.routeAdminCandidates);
        }
      },
    );
  }

  /// Uploads a document on behalf of the selected candidate
  /// Document is created with approved status by default
  /// Sends email notification to candidate
  Future<void> uploadDocumentForCandidate({
    required String docTypeId,
    required String title,
    required String documentName,
    required PlatformFile platformFile,
    DateTime? expiryDate,
    bool hasNoExpiry = false,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final candidate = selectedCandidate.value;
    final profile = selectedCandidateProfile.value;

    if (candidate == null) {
      errorMessage.value = 'Candidate not selected';
      isLoading.value = false;
      AppSnackbar.error('Candidate not selected');
      return;
    }

    final candidateId = candidate.userId;
    final candidateEmail = candidate.email;
    final candidateName = profile != null
        ? AppCandidateProfileFormatters.getFullName(profile)
        : candidateEmail;

    // Check if document type already exists for this candidate
    final existingDocs = candidateDocuments.where(
      (doc) => doc.docTypeId == docTypeId,
    ).toList();

    if (existingDocs.isNotEmpty) {
      errorMessage.value = 'This document type has already been uploaded for this candidate';
      isLoading.value = false;
      AppSnackbar.error('This document type has already been uploaded for this candidate');
      return;
    }

    // Get document type name for email
    final repositoryImpl = documentRepository as DocumentRepositoryImpl;
    String documentTypeName = title;
    try {
      final allDocTypes = await documentRepository.getDocumentTypes();
      allDocTypes.fold(
        (failure) => null,
        (docTypes) {
          DocumentTypeEntity? docType;
          try {
            docType = docTypes.firstWhere(
              (dt) => dt.docTypeId == docTypeId,
            );
          } catch (e) {
            docType = null;
          }
          if (docType != null) {
            documentTypeName = docType.name;
          }
        },
      );
    } catch (e) {
      // Use title if document type not found
    }

    // Upload document with approved status
    final uploadResult = await repositoryImpl.createDocumentForAdmin(
      candidateId: candidateId,
      docTypeId: docTypeId,
      documentName: documentName,
      platformFile: platformFile,
      title: title,
      onProgress: (progress) {
        // Progress tracking if needed
      },
      expiryDate: expiryDate,
      hasNoExpiry: hasNoExpiry,
    );

    uploadResult.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to upload document: ${failure.message}');
      },
      (document) async {
        // Send email notification to candidate
        final emailResult = await sendAdminDocumentUploadEmailUseCase(
          candidateEmail: candidateEmail,
          candidateName: candidateName,
          documentName: documentTypeName,
        );

        emailResult.fold(
          (failure) {
            // Email failed but document is uploaded - show warning
            isLoading.value = false;
            AppSnackbar.warning(
              'Document uploaded successfully, but failed to send email: ${failure.message}',
            );
          },
          (_) {
            isLoading.value = false;
            AppSnackbar.success('Document uploaded successfully');
            AppSnackbar.success('Email notification sent to candidate');
            // Reload documents to show the new upload
            loadCandidateDocuments(candidateId);
            // Navigate back to candidate details screen
            Get.offNamedUntil(
              AppConstants.routeAdminCandidateDetails,
              (route) =>
                  route.settings.name == AppConstants.routeAdminCandidateDetails,
            );
          },
        );
      },
    );
  }

  /// Pick file for admin document upload
  Future<void> pickFileForAdminUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // Validate file
      final validationError = AppFileValidator.validateFile(file);
      if (validationError != null) {
        errorMessage.value = validationError;
        AppSnackbar.error(validationError);
        return;
      }

      selectedFile.value = file;
      selectedFileName.value = file.name;
      selectedFileSize.value = AppFileValidator.formatFileSize(file.size);
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Failed to pick file: $e';
      AppSnackbar.error('Failed to pick file: $e');
    }
  }

  /// Clear selected file for admin document upload
  void clearSelectedFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
    selectedFileSize.value = '';
  }
}
