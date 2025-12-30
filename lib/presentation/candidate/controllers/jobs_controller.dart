import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/usecases/job/get_jobs_usecase.dart';
import 'package:ats/domain/usecases/application/create_application_usecase.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class JobsController extends GetxController {
  final JobRepository jobRepository;
  final ApplicationRepository applicationRepository;
  final CandidateAuthRepository authRepository;

  JobsController(this.jobRepository, this.applicationRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final jobs = <JobEntity>[].obs;
  final selectedJob = Rxn<JobEntity>();
  final applications = <ApplicationEntity>[].obs;

  final getJobsUseCase = GetJobsUseCase(Get.find<JobRepository>());
  final createApplicationUseCase = CreateApplicationUseCase(Get.find<ApplicationRepository>());

  // Stream subscriptions
  StreamSubscription<List<JobEntity>>? _jobsSubscription;
  StreamSubscription<List<ApplicationEntity>>? _applicationsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    loadApplications();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _jobsSubscription?.cancel();
    _applicationsSubscription?.cancel();
    super.onClose();
  }

  void loadJobs() {
    _jobsSubscription?.cancel(); // Cancel previous subscription if exists
    _jobsSubscription = jobRepository.streamJobs(status: AppConstants.jobStatusOpen).listen(
      (jobsList) {
        jobs.value = jobsList;
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
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
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
  }

  void selectJob(JobEntity job) {
    selectedJob.value = job;
  }

  bool hasApplied(String jobId) {
    return applications.any((app) => app.jobId == jobId);
  }

  Future<void> applyToJob(String jobId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) {
      errorMessage.value = 'User not authenticated';
      isLoading.value = false;
      return;
    }

    if (hasApplied(jobId)) {
      errorMessage.value = 'You have already applied to this job';
      isLoading.value = false;
      return;
    }

    final result = await createApplicationUseCase(
      candidateId: currentUser.userId,
      jobId: jobId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (application) {
        isLoading.value = false;
        AppSnackbar.success('Application submitted successfully');
      },
    );
  }
}

