import 'package:get/get.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/core/constants/app_constants.dart';

class AdminDashboardController extends GetxController {
  final ApplicationRepository applicationRepository;
  final JobRepository jobRepository;

  AdminDashboardController(this.applicationRepository, this.jobRepository);

  final isLoading = false.obs;
  final totalApplicationsCount = 0.obs;
  final pendingApplicationsCount = 0.obs;
  final approvedApplicationsCount = 0.obs;
  final rejectedApplicationsCount = 0.obs;
  final openJobsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  void loadStats() {
    // Load all applications count (total applied)
    applicationRepository.streamApplications().listen((apps) {
      totalApplicationsCount.value = apps.length;
    });

    // Load pending applications count
    applicationRepository
        .streamApplications(status: AppConstants.applicationStatusPending)
        .listen((apps) {
      pendingApplicationsCount.value = apps.length;
    });

    // Load approved applications count
    applicationRepository
        .streamApplications(status: AppConstants.applicationStatusApproved)
        .listen((apps) {
      approvedApplicationsCount.value = apps.length;
    });

    // Load rejected/denied applications count
    applicationRepository
        .streamApplications(status: AppConstants.applicationStatusDenied)
        .listen((apps) {
      rejectedApplicationsCount.value = apps.length;
    });

    // Load open jobs count
    jobRepository.streamJobs(status: AppConstants.jobStatusOpen).listen((jobs) {
      openJobsCount.value = jobs.length;
    });
  }
}

