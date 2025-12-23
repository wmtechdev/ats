import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/usecases/job/create_job_usecase.dart';
import 'package:ats/domain/usecases/job/update_job_usecase.dart';
import 'package:ats/domain/usecases/job/delete_job_usecase.dart';

class AdminJobsController extends GetxController {
  final JobRepository jobRepository;
  final ApplicationRepository applicationRepository;

  AdminJobsController(this.jobRepository, this.applicationRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final jobs = <JobEntity>[].obs;
  final filteredJobs = <JobEntity>[].obs;
  final selectedJob = Rxn<JobEntity>();
  final selectedStatusFilter = Rxn<String>(); // null = all, 'open', 'closed'
  final searchQuery = ''.obs;
  final jobApplicationCounts = <String, int>{}.obs;

  final createJobUseCase = CreateJobUseCase(Get.find<JobRepository>());
  final updateJobUseCase = UpdateJobUseCase(Get.find<JobRepository>());
  final deleteJobUseCase = DeleteJobUseCase(Get.find<JobRepository>());

  // Stream subscriptions
  StreamSubscription<List<JobEntity>>? _jobsSubscription;
  StreamSubscription? _applicationsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    loadApplicationCounts();
  }

  @override
  void onClose() {
    _jobsSubscription?.cancel();
    _applicationsSubscription?.cancel();
    super.onClose();
  }

  void loadJobs() {
    _jobsSubscription?.cancel();
    _jobsSubscription = jobRepository.streamJobs().listen(
      (jobsList) {
        jobs.value = jobsList;
        _applyFilters();
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }

  void loadApplicationCounts() {
    _applicationsSubscription?.cancel();
    _applicationsSubscription = applicationRepository.streamApplications().listen(
      (applications) {
        final counts = <String, int>{};
        for (var app in applications) {
          counts[app.jobId] = (counts[app.jobId] ?? 0) + 1;
        }
        jobApplicationCounts.value = counts;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }

  int getApplicationCount(String jobId) {
    return jobApplicationCounts[jobId] ?? 0;
  }

  void setStatusFilter(String? status) {
    selectedStatusFilter.value = status;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<JobEntity>.from(jobs);

    // Apply status filter
    if (selectedStatusFilter.value != null) {
      filtered = filtered
          .where((job) => job.status == selectedStatusFilter.value)
          .toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((job) =>
              job.title.toLowerCase().contains(query) ||
              job.description.toLowerCase().contains(query))
          .toList();
    }

    filteredJobs.value = filtered;
  }

  void selectJob(JobEntity job) {
    selectedJob.value = job;
  }

  Future<void> createJob({
    required String title,
    required String description,
    required String requirements,
    required List<String> requiredDocumentIds,
  }) async {
    if (!_validateJob(title, description, requirements)) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await createJobUseCase(
      title: title,
      description: description,
      requirements: requirements,
      requiredDocumentIds: requiredDocumentIds,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar('Error', failure.message);
      },
      (job) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job created successfully');
        Get.offNamedUntil(
          AppConstants.routeAdminJobs,
          (route) => route.settings.name == AppConstants.routeAdminJobs,
        );
      },
    );
  }

  Future<void> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? requirements,
    List<String>? requiredDocumentIds,
    String? status,
  }) async {
    if (title != null || description != null || requirements != null) {
      if (!_validateJob(
        title ?? selectedJob.value?.title ?? '',
        description ?? selectedJob.value?.description ?? '',
        requirements ?? selectedJob.value?.requirements ?? '',
      )) {
        return;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

      final result = await updateJobUseCase(
      jobId: jobId,
      title: title,
      description: description,
      requirements: requirements,
      requiredDocumentIds: requiredDocumentIds,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar('Error', failure.message);
      },
      (job) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job updated successfully');
        Get.offNamedUntil(
          AppConstants.routeAdminJobs,
          (route) => route.settings.name == AppConstants.routeAdminJobs,
        );
      },
    );
  }

  Future<void> changeJobStatus(String jobId, String status) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateJobUseCase(
      jobId: jobId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar('Error', failure.message);
      },
      (job) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job status updated successfully');
      },
    );
  }

  Future<void> deleteJob(String jobId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await deleteJobUseCase(jobId);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar('Error', failure.message);
      },
      (_) {
        isLoading.value = false;
        Get.snackbar('Success', 'Job deleted successfully');
      },
    );
  }

  bool _validateJob(String title, String description, String requirements) {
    if (title.trim().isEmpty) {
      Get.snackbar('Error', 'Job title is required');
      return false;
    }
    if (title.trim().length < 3) {
      Get.snackbar('Error', 'Job title must be at least 3 characters');
      return false;
    }
    if (description.trim().isEmpty) {
      Get.snackbar('Error', 'Job description is required');
      return false;
    }
    if (description.trim().length < 10) {
      Get.snackbar('Error', 'Job description must be at least 10 characters');
      return false;
    }
    if (requirements.trim().isEmpty) {
      Get.snackbar('Error', 'Requirements are required');
      return false;
    }
    return true;
  }
}
