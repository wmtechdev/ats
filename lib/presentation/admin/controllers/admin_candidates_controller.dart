import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/usecases/application/update_application_status_usecase.dart';
import 'package:ats/domain/usecases/document/update_document_status_usecase.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/app_widgets.dart';

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

  late final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;
  late final UpdateDocumentStatusUseCase updateDocumentStatusUseCase;

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
    loadCandidates();
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
    _candidateDocumentsSubscriptions.clear();
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
    candidateProfileRepository.getProfile(userId).then((result) {
      result.fold(
        (failure) => null,
        (profile) {
          candidateProfiles[userId] = profile;
          candidateProfiles.refresh(); // Trigger reactivity
          _applyFilters(); // Re-apply filters when profile loads
        },
      );
    }).catchError((error) {
      // Silently handle errors
    });
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
}

