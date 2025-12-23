import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/usecases/document/upload_document_usecase.dart';
import 'package:file_picker/file_picker.dart';

class DocumentsController extends GetxController {
  final DocumentRepository documentRepository;
  final CandidateAuthRepository authRepository;

  DocumentsController(this.documentRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final documentTypes = <DocumentTypeEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;

  final uploadDocumentUseCase = UploadDocumentUseCase(Get.find<DocumentRepository>());

  // Stream subscriptions
  StreamSubscription<List<DocumentTypeEntity>>? _documentTypesSubscription;
  StreamSubscription<List<CandidateDocumentEntity>>? _candidateDocumentsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDocumentTypes();
    loadCandidateDocuments();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _documentTypesSubscription?.cancel();
    _candidateDocumentsSubscription?.cancel();
    super.onClose();
  }

  void loadDocumentTypes() {
    _documentTypesSubscription?.cancel(); // Cancel previous subscription if exists
    _documentTypesSubscription = documentRepository.streamDocumentTypes().listen(
      (types) {
        documentTypes.value = types;
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
  }

  void loadCandidateDocuments() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    _candidateDocumentsSubscription?.cancel(); // Cancel previous subscription if exists
    _candidateDocumentsSubscription = documentRepository
        .streamCandidateDocuments(currentUser.userId)
        .listen(
      (docs) {
        candidateDocuments.value = docs;
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
  }

  bool hasDocument(String docTypeId) {
    return candidateDocuments.any((doc) => doc.docTypeId == docTypeId);
  }

  CandidateDocumentEntity? getDocumentByType(String docTypeId) {
    try {
      return candidateDocuments.firstWhere((doc) => doc.docTypeId == docTypeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadDocument(String docTypeId, String docTypeName) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        isLoading.value = false;
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        errorMessage.value = 'File path is null';
        isLoading.value = false;
        return;
      }

      final currentUser = authRepository.getCurrentUser();
      if (currentUser == null) {
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      final documentName = '${currentUser.userId}_${docTypeName}_${file.name}';

      final uploadResult = await uploadDocumentUseCase(
        candidateId: currentUser.userId,
        docTypeId: docTypeId,
        documentName: documentName,
        filePath: file.path!,
      );

      uploadResult.fold(
        (failure) {
          errorMessage.value = failure.message;
          isLoading.value = false;
        },
        (document) {
          isLoading.value = false;
          Get.snackbar('Success', 'Document uploaded successfully');
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to pick file: $e';
      isLoading.value = false;
    }
  }
}

