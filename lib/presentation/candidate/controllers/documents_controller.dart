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
  final searchQuery = ''.obs;
  final filteredDocumentTypes = <DocumentTypeEntity>[].obs;
  final filteredUserDocuments = <CandidateDocumentEntity>[].obs;

  // File selection for user document creation
  final selectedFile = Rxn<PlatformFile>();
  final selectedFileName = ''.obs;

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
    // Clear selected file when controller is disposed
    clearSelectedFile();
    super.onClose();
  }

  void loadDocumentTypes() {
    _documentTypesSubscription?.cancel(); // Cancel previous subscription if exists
    _documentTypesSubscription = documentRepository.streamDocumentTypes().listen(
      (types) {
        documentTypes.value = types;
        filterDocuments();
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
        filterDocuments();
      },
      onError: (error) {
        // Silently handle permission errors (user might have signed out)
        // Don't show errors for permission-denied as it's expected after sign-out
      },
    );
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterDocuments();
  }

  void filterDocuments() {
    final query = searchQuery.value.toLowerCase().trim();
    
    // Filter document types
    if (query.isEmpty) {
      filteredDocumentTypes.value = documentTypes.toList();
    } else {
      filteredDocumentTypes.value = documentTypes.where((docType) {
        return docType.name.toLowerCase().contains(query) ||
            docType.description.toLowerCase().contains(query);
      }).toList();
    }

    // Filter user-added documents
    final userDocs = candidateDocuments.where((doc) => doc.isUserAdded).toList();
    if (query.isEmpty) {
      filteredUserDocuments.value = userDocs;
    } else {
      filteredUserDocuments.value = userDocs.where((doc) {
        final title = doc.title?.toLowerCase() ?? '';
        final description = doc.description?.toLowerCase() ?? '';
        return title.contains(query) || description.contains(query);
      }).toList();
    }
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

  bool hasAllRequiredDocuments(List<String> requiredDocumentIds) {
    if (requiredDocumentIds.isEmpty) return true;
    return requiredDocumentIds.every((docTypeId) => hasDocument(docTypeId));
  }

  List<String> getMissingRequiredDocuments(List<String> requiredDocumentIds) {
    return requiredDocumentIds.where((docTypeId) => !hasDocument(docTypeId)).toList();
  }

  DocumentTypeEntity? getDocumentTypeById(String docTypeId) {
    try {
      return documentTypes.firstWhere((docType) => docType.docTypeId == docTypeId);
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

  Future<void> pickFileForUserDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        errorMessage.value = 'File path is null';
        Get.snackbar('Error', 'File path is null');
        return;
      }

      selectedFile.value = file;
      selectedFileName.value = file.name;
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Failed to pick file: $e';
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }

  void clearSelectedFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
  }

  Future<void> createUserDocument({
    required String title,
    required String description,
  }) async {
    // Validate file is selected
    if (selectedFile.value == null || selectedFile.value!.path == null) {
      errorMessage.value = 'Please select a document file';
      Get.snackbar('Error', 'Please select a document file');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final file = selectedFile.value!;
      final currentUser = authRepository.getCurrentUser();
      if (currentUser == null) {
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final documentName = '${currentUser.userId}_${title}_${file.name}';

      final createResult = await documentRepository.createUserDocument(
        candidateId: currentUser.userId,
        title: title,
        description: description,
        documentName: documentName,
        filePath: file.path!,
      );

      createResult.fold(
        (failure) {
          errorMessage.value = failure.message;
          isLoading.value = false;
          Get.snackbar('Error', failure.message);
        },
        (document) {
          isLoading.value = false;
          clearSelectedFile();
          Get.snackbar('Success', 'Document created successfully');
          Get.back();
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to create document: $e';
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to create document: $e');
    }
  }
}

