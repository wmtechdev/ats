import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/core/constants/app_constants.dart';

class CandidateDashboardController extends GetxController {
  final CandidateAuthRepository authRepository;
  final ApplicationRepository applicationRepository;
  final JobRepository jobRepository;
  final DocumentRepository documentRepository;

  CandidateDashboardController(
    this.authRepository,
    this.applicationRepository,
    this.jobRepository,
    this.documentRepository,
  );

  final isLoading = false.obs;
  final totalApplicationsCount = 0.obs;
  final availableJobsCount = 0.obs;
  final pendingDocumentsCount = 0.obs;
  final approvedDocumentsCount = 0.obs;
  final rejectedDocumentsCount = 0.obs;

  // Stream subscriptions
  StreamSubscription? _totalAppsSubscription;
  StreamSubscription? _jobsSubscription;
  StreamSubscription? _allDocumentsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _totalAppsSubscription?.cancel();
    _jobsSubscription?.cancel();
    _allDocumentsSubscription?.cancel();
    super.onClose();
  }

  void loadStats() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    // Load all applications count (total applied by this candidate)
    _totalAppsSubscription?.cancel();
    _totalAppsSubscription = applicationRepository
        .streamApplications(candidateId: currentUser.userId)
        .listen(
      (apps) {
        totalApplicationsCount.value = apps.length;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );

    // Load available jobs count (open jobs)
    _jobsSubscription?.cancel();
    _jobsSubscription = jobRepository
        .streamJobs(status: AppConstants.jobStatusOpen)
        .listen(
      (jobs) {
        availableJobsCount.value = jobs.length;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );

    // Load documents count by status
    _allDocumentsSubscription?.cancel();
    _allDocumentsSubscription = documentRepository
        .streamCandidateDocuments(currentUser.userId)
        .listen(
      (documents) {
        pendingDocumentsCount.value = documents
            .where((doc) => doc.status == AppConstants.documentStatusPending)
            .length;
        approvedDocumentsCount.value = documents
            .where((doc) => doc.status == AppConstants.documentStatusApproved)
            .length;
        rejectedDocumentsCount.value = documents
            .where((doc) => doc.status == AppConstants.documentStatusDenied)
            .length;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }
}

