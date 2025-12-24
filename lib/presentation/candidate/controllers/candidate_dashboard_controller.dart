import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/core/constants/app_constants.dart';

class CandidateDashboardController extends GetxController {
  final CandidateAuthRepository authRepository;
  final ApplicationRepository applicationRepository;
  final JobRepository jobRepository;

  CandidateDashboardController(
    this.authRepository,
    this.applicationRepository,
    this.jobRepository,
  );

  final isLoading = false.obs;
  final totalApplicationsCount = 0.obs;
  final pendingApplicationsCount = 0.obs;
  final approvedApplicationsCount = 0.obs;
  final rejectedApplicationsCount = 0.obs;
  final availableJobsCount = 0.obs;

  // Stream subscriptions
  StreamSubscription? _totalAppsSubscription;
  StreamSubscription? _pendingAppsSubscription;
  StreamSubscription? _approvedAppsSubscription;
  StreamSubscription? _rejectedAppsSubscription;
  StreamSubscription? _jobsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _totalAppsSubscription?.cancel();
    _pendingAppsSubscription?.cancel();
    _approvedAppsSubscription?.cancel();
    _rejectedAppsSubscription?.cancel();
    _jobsSubscription?.cancel();
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

    // Load pending applications count
    _pendingAppsSubscription?.cancel();
    _pendingAppsSubscription = applicationRepository
        .streamApplications(
          candidateId: currentUser.userId,
          status: AppConstants.applicationStatusPending,
        )
        .listen(
      (apps) {
        pendingApplicationsCount.value = apps.length;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );

    // Load approved applications count
    _approvedAppsSubscription?.cancel();
    _approvedAppsSubscription = applicationRepository
        .streamApplications(
          candidateId: currentUser.userId,
          status: AppConstants.applicationStatusApproved,
        )
        .listen(
      (apps) {
        approvedApplicationsCount.value = apps.length;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );

    // Load rejected/denied applications count
    _rejectedAppsSubscription?.cancel();
    _rejectedAppsSubscription = applicationRepository
        .streamApplications(
          candidateId: currentUser.userId,
          status: AppConstants.applicationStatusDenied,
        )
        .listen(
      (apps) {
        rejectedApplicationsCount.value = apps.length;
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
  }
}

