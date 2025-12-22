import 'package:get/get.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/usecases/document/upload_document_usecase.dart';
import 'package:file_picker/file_picker.dart';

class DocumentsController extends GetxController {
  final DocumentRepository documentRepository;
  final AuthRepository authRepository;

  DocumentsController(this.documentRepository, this.authRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final documentTypes = <DocumentTypeEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;

  final uploadDocumentUseCase = UploadDocumentUseCase(Get.find<DocumentRepository>());

  @override
  void onInit() {
    super.onInit();
    loadDocumentTypes();
    loadCandidateDocuments();
  }

  void loadDocumentTypes() {
    documentRepository.streamDocumentTypes().listen((types) {
      documentTypes.value = types;
    });
  }

  void loadCandidateDocuments() {
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) return;

    documentRepository
        .streamCandidateDocuments(currentUser.userId)
        .listen((docs) {
      candidateDocuments.value = docs;
    });
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

