import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/usecases/application/create_application_usecase.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class ApplicationsController extends GetxController {
  final ApplicationRepository applicationRepository;
  final CandidateAuthRepository authRepository;

  ApplicationsController(this.applicationRepository, this.authRepository);

  final createApplicationUseCase = CreateApplicationUseCase(Get.find<ApplicationRepository>());

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

  Future<void> reapplyToJob(String jobId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) {
      errorMessage.value = 'User not authenticated';
      isLoading.value = false;
      AppSnackbar.error('User not authenticated');
      return;
    }

    // Find and delete the old denied application for this job
    final deniedApp = applications.firstWhereOrNull(
      (app) => app.jobId == jobId && app.status == AppConstants.applicationStatusDenied,
    );

    if (deniedApp != null) {
      // Delete the old denied application from Firestore
      try {
        final deleteResult = await applicationRepository.deleteApplication(
          applicationId: deniedApp.applicationId,
        );
        deleteResult.fold(
          (failure) {
            // Continue - deletion failure shouldn't block reapply
          },
          (_) {
            // Successfully deleted
          },
        );
      } catch (e) {
        // Continue - deletion failure shouldn't block reapply
      }
    }

    // Create new application
    final result = await createApplicationUseCase(
      candidateId: currentUser.userId,
      jobId: jobId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        AppSnackbar.error(failure.message);
      },
      (application) {
        isLoading.value = false;
        AppSnackbar.success('Application submitted successfully');
      },
    );
  }
}

