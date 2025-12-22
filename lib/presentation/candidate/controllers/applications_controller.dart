import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/job_entity.dart';

class ApplicationsController extends GetxController {
  final ApplicationRepository applicationRepository;
  final AuthRepository authRepository;

  ApplicationsController(this.applicationRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final applications = <ApplicationEntity>[].obs;
  final jobs = <String, JobEntity>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  void loadApplications() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    applicationRepository
        .streamApplications(candidateId: currentUser.userId)
        .listen((appsList) {
      applications.value = appsList;
      // Load job details for each application
      for (final app in appsList) {
        loadJobDetails(app.jobId);
      }
    });
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

