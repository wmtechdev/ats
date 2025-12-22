import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/usecases/job/get_jobs_usecase.dart';
import 'package:ats/domain/usecases/application/create_application_usecase.dart';

class JobsController extends GetxController {
  final JobRepository jobRepository;
  final ApplicationRepository applicationRepository;
  final AuthRepository authRepository;

  JobsController(this.jobRepository, this.applicationRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final jobs = <JobEntity>[].obs;
  final selectedJob = Rxn<JobEntity>();
  final applications = <ApplicationEntity>[].obs;

  final getJobsUseCase = GetJobsUseCase(Get.find<JobRepository>());
  final createApplicationUseCase = CreateApplicationUseCase(Get.find<ApplicationRepository>());

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    loadApplications();
  }

  void loadJobs() {
    jobRepository.streamJobs(status: AppConstants.jobStatusOpen).listen((jobsList) {
      jobs.value = jobsList;
    });
  }

  void loadApplications() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    applicationRepository
        .streamApplications(candidateId: currentUser.userId)
        .listen((appsList) {
      applications.value = appsList;
    });
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
        Get.snackbar('Success', 'Application submitted successfully');
      },
    );
  }
}

