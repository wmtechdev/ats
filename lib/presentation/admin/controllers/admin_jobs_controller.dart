import 'package:get/get.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/usecases/job/create_job_usecase.dart';

class AdminJobsController extends GetxController {
  final JobRepository jobRepository;

  AdminJobsController(this.jobRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final jobs = <JobEntity>[].obs;
  final selectedJob = Rxn<JobEntity>();

  final createJobUseCase = CreateJobUseCase(Get.find<JobRepository>());

  @override
  void onInit() {
    super.onInit();
    loadJobs();
  }

  void loadJobs() {
    jobRepository.streamJobs().listen((jobsList) {
      jobs.value = jobsList;
    });
  }

  void selectJob(JobEntity job) {
    selectedJob.value = job;
  }

  Future<void> createJob({
    required String title,
    required String description,
    required String hospitalName,
    required List<String> requirements,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await createJobUseCase(
      title: title,
      description: description,
      hospitalName: hospitalName,
      requirements: requirements,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (job) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job created successfully');
        Get.back();
      },
    );
  }

  Future<void> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? hospitalName,
    List<String>? requirements,
    String? status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await jobRepository.updateJob(
      jobId: jobId,
      title: title,
      description: description,
      hospitalName: hospitalName,
      requirements: requirements,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (job) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job updated successfully');
        Get.back();
      },
    );
  }

  Future<void> deleteJob(String jobId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await jobRepository.deleteJob(jobId);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job deleted successfully');
      },
    );
  }
}

