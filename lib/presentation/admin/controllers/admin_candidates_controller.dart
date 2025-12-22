import 'package:get/get.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/usecases/application/update_application_status_usecase.dart';
import 'package:ats/domain/usecases/document/update_document_status_usecase.dart';

class AdminCandidatesController extends GetxController {
  final AdminRepository adminRepository;
  final ApplicationRepository applicationRepository;
  final DocumentRepository documentRepository;

  AdminCandidatesController(
    this.adminRepository,
    this.applicationRepository,
    this.documentRepository,
  );

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final candidates = <UserEntity>[].obs;
  final selectedCandidate = Rxn<UserEntity>();
  final candidateApplications = <ApplicationEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;

  final updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(Get.find<ApplicationRepository>());
  final updateDocumentStatusUseCase = UpdateDocumentStatusUseCase(Get.find<DocumentRepository>());

  @override
  void onInit() {
    super.onInit();
    loadCandidates();
  }

  void loadCandidates() {
    adminRepository.getCandidates().then((result) {
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (candidatesList) => candidates.value = candidatesList,
      );
    });
  }

  void selectCandidate(UserEntity candidate) {
    selectedCandidate.value = candidate;
    loadCandidateApplications(candidate.userId);
    loadCandidateDocuments(candidate.userId);
  }

  void loadCandidateApplications(String candidateId) {
    applicationRepository
        .streamApplications(candidateId: candidateId)
        .listen((apps) {
      candidateApplications.value = apps;
    });
  }

  void loadCandidateDocuments(String candidateId) {
    documentRepository
        .streamCandidateDocuments(candidateId)
        .listen((docs) {
      candidateDocuments.value = docs;
    });
  }

  Future<void> updateDocumentStatus({
    required String candidateDocId,
    required String status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateDocumentStatusUseCase(
      candidateDocId: candidateDocId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (document) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document status updated');
      },
    );
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateApplicationStatusUseCase(
      applicationId: applicationId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (application) {
        isLoading.value = false;
        Get.snackbar('Success', 'Application status updated');
      },
    );
  }
}

