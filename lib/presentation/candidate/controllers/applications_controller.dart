import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/job_entity.dart';

class ApplicationsController extends GetxController {
  final ApplicationRepository applicationRepository;
  final CandidateAuthRepository authRepository;

  ApplicationsController(this.applicationRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final applications = <ApplicationEntity>[].obs;
  final jobs = <String, JobEntity>{}.obs;

  // Stream subscription
  StreamSubscription<List<ApplicationEntity>>? _applicationsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  @override
  void onClose() {
    // Cancel stream subscription to prevent permission errors after sign-out
    _applicationsSubscription?.cancel();
    super.onClose();
  }

  void loadApplications() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    _applicationsSubscription?.cancel(); // Cancel previous subscription if exists
    _applicationsSubscription = applicationRepository
        .streamApplications(candidateId: currentUser.userId)
        .listen(
      (appsList) {
        applications.value = appsList;
        // Load job details for each application
        for (final app in appsList) {
          loadJobDetails(app.jobId);
        }
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
  }

  Future<void> loadJobDetails(String jobId) async {
    if (jobs.containsKey(jobId)) return;

    final jobRepo = Get.find<JobRepository>();
    final result = await jobRepo.getJob(jobId);
    result.fold(
      (failure) => null,
      (job) => jobs[jobId] = job,
    );
  }

  String getStatusText(String status) {
    switch (status) {
      case AppConstants.applicationStatusPending:
        return 'Pending';
      case AppConstants.applicationStatusReviewed:
        return 'Under Review';
      case AppConstants.applicationStatusApproved:
        return 'Approved';
      case AppConstants.applicationStatusDenied:
        return 'Denied';
      default:
        return status;
    }
  }
}

