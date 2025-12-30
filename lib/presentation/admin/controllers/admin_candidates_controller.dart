import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/usecases/application/update_application_status_usecase.dart';
import 'package:ats/domain/usecases/document/update_document_status_usecase.dart';
import 'package:ats/domain/usecases/email/send_document_denial_email_usecase.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/app_widgets.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
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
  final applicationJobs = <String, JobEntity?>{}.obs;
  final availableAgents = <AdminProfileEntity>[].obs;
  final candidateProfileStreams = <String, StreamSubscription<CandidateProfileEntity?>>{};

  late final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;
  late final UpdateDocumentStatusUseCase updateDocumentStatusUseCase;
  late final SendDocumentDenialEmailUseCase sendDocumentDenialEmailUseCase;

  // Stream subscriptions
  StreamSubscription<List<ApplicationEntity>>? _applicationsSubscription;
  StreamSubscription<List<CandidateDocumentEntity>>? _documentsSubscription;
  StreamSubscription<CandidateProfileEntity?>? _profileSubscription;
  final Map<String, StreamSubscription<List<CandidateDocumentEntity>>> _candidateDocumentsSubscriptions = {};

  @override
  void onInit() {
    super.onInit();
    // Initialize use cases after repositories are registered
    updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(Get.find<ApplicationRepository>());
    updateDocumentStatusUseCase = UpdateDocumentStatusUseCase(Get.find<DocumentRepository>());
    sendDocumentDenialEmailUseCase = SendDocumentDenialEmailUseCase(Get.find<EmailRepository>());
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
    super.onClose();
  }

  void loadCandidates() {
    isLoading.value = true;
    errorMessage.value = '';
    
    adminRepository.getCandidates().then((result) {
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
    }).catchError((error) {
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
    _applicationsSubscription?.cancel(); // Cancel previous subscription if exists
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
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
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

    final documentName = document.title ?? document.documentName;
    final candidateEmail = candidate.email;
    final candidateName = profile != null
        ? '${profile.firstName} ${profile.lastName}'.trim()
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

  /// Updates document status after email is sent successfully
  void _updateDocumentStatusAfterEmail(String candidateDocId, String status) async {
    final result = await updateDocumentStatusUseCase(
      candidateDocId: candidateDocId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error('Failed to update document status: ${failure.message}');
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
    return '${profile.firstName} ${profile.lastName}'.trim();
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
    final hasRejected = documents.any((doc) => 
      doc.status == AppConstants.documentStatusDenied);
    if (hasRejected) {
      return AppConstants.documentStatusDenied;
    }
    
    // Check if any document is pending
    final hasPending = documents.any((doc) => doc.status == AppConstants.documentStatusPending);
    if (hasPending) {
      return AppConstants.documentStatusPending;
    }
    
    // Check if all documents are approved
    final allApproved = documents.every((doc) => doc.status == AppConstants.documentStatusApproved);
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
        .map((work) => '${work['company'] ?? 'N/A'} - ${work['position'] ?? 'N/A'}')
        .join('\n');
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
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

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((candidate) {
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
    adminRepository.getAllAdminProfiles().then((result) {
      result.fold(
        (failure) {
          AppSnackbar.error('Failed to load agents: ${failure.message}');
        },
        (profiles) {
          availableAgents.value = profiles;
        },
      );
    }).catchError((error) {
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
    required String? agentId, // This is the profileId from adminProfiles collection
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
}

