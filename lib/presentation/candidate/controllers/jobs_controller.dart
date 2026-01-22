import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/usecases/job/get_jobs_usecase.dart';
import 'package:ats/domain/usecases/application/create_application_usecase.dart';
import 'package:ats/domain/usecases/email/send_missing_documents_email_usecase.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class JobsController extends GetxController {
  final JobRepository jobRepository;
  final ApplicationRepository applicationRepository;
  final CandidateAuthRepository authRepository;
  final CandidateProfileRepository profileRepository;
  final DocumentRepository documentRepository;
  final EmailRepository emailRepository;

  JobsController(
    this.jobRepository,
    this.applicationRepository,
    this.authRepository,
    this.profileRepository,
    this.documentRepository,
    this.emailRepository,
  );

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final jobs = <JobEntity>[].obs;
  final selectedJob = Rxn<JobEntity>();
  final applications = <ApplicationEntity>[].obs;

  final getJobsUseCase = GetJobsUseCase(Get.find<JobRepository>());
  final createApplicationUseCase = CreateApplicationUseCase(
    Get.find<ApplicationRepository>(),
    Get.find<JobRepository>(),
  );

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
    _jobsSubscription = jobRepository
        .streamJobs(status: AppConstants.jobStatusOpen)
        .listen(
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

    _applicationsSubscription
        ?.cancel(); // Cancel previous subscription if exists
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

    // Get job details
    final jobResult = await jobRepository.getJob(jobId);
    
    await jobResult.fold(
      (failure) async {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (job) async {
        // Create application
        final result = await createApplicationUseCase(
          candidateId: currentUser.userId,
          jobId: jobId,
        );

        result.fold(
          (failure) {
            errorMessage.value = failure.message;
            isLoading.value = false;
          },
          (application) async {
            isLoading.value = false;
            AppSnackbar.success('Application submitted successfully');
            
            // Navigate to My Applications screen
            Get.offNamed(AppConstants.routeCandidateApplications);
            
            // Check for missing documents and send email if any
            if (application.requiredDocumentIds.isNotEmpty) {
              final missingDocIds = application.requiredDocumentIds
                  .where((docId) => !application.uploadedDocumentIds.contains(docId))
                  .toList();
              
              if (missingDocIds.isNotEmpty) {
                // Get candidate profile for name
                final profileResult = await profileRepository.getProfile(currentUser.userId);
                profileResult.fold(
                  (_) {},
                  (profile) async {
                    // Get document types for missing documents
                    // Use streamDocumentTypesForCandidate to get all types including candidate-specific
                    final docTypesStream = documentRepository.streamDocumentTypesForCandidate(
                      currentUser.userId,
                    );
                    
                    // Convert stream to Future using Completer
                    final completer = Completer<List<DocumentTypeEntity>>();
                    StreamSubscription<List<DocumentTypeEntity>>? docTypesSubscription;
                    
                    docTypesSubscription = docTypesStream.timeout(
                      const Duration(seconds: 5),
                      onTimeout: (sink) {
                        sink.close();
                        if (!completer.isCompleted) {
                          completer.complete([]);
                        }
                      },
                    ).listen(
                      (docTypes) {
                        docTypesSubscription?.cancel();
                        if (!completer.isCompleted) {
                          completer.complete(docTypes);
                        }
                      },
                      onError: (error) {
                        docTypesSubscription?.cancel();
                        if (!completer.isCompleted) {
                          completer.complete([]);
                        }
                      },
                    );
                    
                    try {
                      final docTypes = await completer.future;
                      
                      final missingDocs = <Map<String, String>>[];
                      for (final docId in missingDocIds) {
                        try {
                          final docType = docTypes.firstWhere(
                            (dt) => dt.docTypeId == docId,
                          );
                          missingDocs.add({
                            'name': docType.name,
                            'description': docType.description,
                          });
                        } catch (e) {
                          // Document type not found, skip
                        }
                      }
                      
                      if (missingDocs.isNotEmpty) {
                        final candidateName = AppCandidateProfileFormatters.getFullName(profile);
                        final candidateEmail = currentUser.email;
                        
                        // Send email
                        final sendEmailUseCase = SendMissingDocumentsEmailUseCase(emailRepository);
                        final emailResult = await sendEmailUseCase(
                          candidateEmail: candidateEmail,
                          candidateName: candidateName,
                          jobTitle: job.title,
                          missingDocuments: missingDocs,
                        );
                        
                        emailResult.fold(
                          (failure) {
                            // Email sending failed, but don't show error to user
                            // Application was successful
                          },
                          (_) {
                            // Email sent successfully
                          },
                        );
                      }
                    } catch (e) {
                      // Error getting document types, skip email
                    }
                  },
                );
              }
            }
          },
        );
      },
    );
  }
}
