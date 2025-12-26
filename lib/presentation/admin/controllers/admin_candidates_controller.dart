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
  final candidateProfiles = <String, CandidateProfileEntity?>{}.obs;
  final selectedCandidate = Rxn<UserEntity>();
  final selectedCandidateProfile = Rxn<CandidateProfileEntity>();
  final candidateApplications = <ApplicationEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;
  final applicationJobs = <String, JobEntity?>{}.obs;

  final updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(Get.find<ApplicationRepository>());
  final updateDocumentStatusUseCase = UpdateDocumentStatusUseCase(Get.find<DocumentRepository>());

  // Stream subscriptions
  StreamSubscription<List<ApplicationEntity>>? _applicationsSubscription;
  StreamSubscription<List<CandidateDocumentEntity>>? _documentsSubscription;
  StreamSubscription<CandidateProfileEntity?>? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    loadCandidates();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _applicationsSubscription?.cancel();
    _documentsSubscription?.cancel();
    _profileSubscription?.cancel();
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
          
          // Load profiles for all candidates
          for (var candidate in candidatesList) {
            loadCandidateProfile(candidate.userId);
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
        Get.snackbar('Success', 'Document status updated');
      },
    );
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
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
      },
      (application) {
        isLoading.value = false;
        Get.snackbar('Success', 'Application status updated');
      },
    );
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
}

