import 'package:get/get.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/core/constants/app_constants.dart';

class AdminDashboardController extends GetxController {
  final ApplicationRepository applicationRepository;
  final JobRepository jobRepository;

  AdminDashboardController(this.applicationRepository, this.jobRepository);

  final isLoading = false.obs;
  final pendingApplicationsCount = 0.obs;
  final openJobsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  void loadStats() {
    // Load pending applications count
    applicationRepository
        .streamApplications(status: AppConstants.applicationStatusPending)
        .listen((apps) {
      pendingApplicationsCount.value = apps.length;
    });

    // Load open jobs count
    jobRepository.streamJobs(status: AppConstants.jobStatusOpen).listen((jobs) {
      openJobsCount.value = jobs.length;
    });
  }
}

