import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/usecases/document/upload_document_usecase.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/data/repositories/document_repository_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class DocumentsController extends GetxController {
  final DocumentRepository documentRepository;
  final CandidateAuthRepository authRepository;

  DocumentsController(this.documentRepository, this.authRepository);

  final isLoading = false.obs;
  final uploadProgress = 0.0.obs;
  final isUploading = false.obs;
  final uploadingDocTypeId =
      ''.obs; // Track which document type is being uploaded
  final errorMessage = ''.obs;
  final documentTypes = <DocumentTypeEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;
  final searchQuery = ''.obs;
  final filteredDocumentTypes = <DocumentTypeEntity>[].obs;
  final filteredUserDocuments = <CandidateDocumentEntity>[].obs;

  // File selection for user document creation
  final selectedFile = Rxn<PlatformFile>();
  final selectedFileName = ''.obs;
  final selectedFileSize = ''.obs;

  final uploadDocumentUseCase = UploadDocumentUseCase(
    Get.find<DocumentRepository>(),
  );

  // Stream subscriptions
  StreamSubscription<List<DocumentTypeEntity>>? _documentTypesSubscription;
  StreamSubscription<List<CandidateDocumentEntity>>?
  _candidateDocumentsSubscription;

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
    // Reset upload progress
    uploadProgress.value = 0.0;
    isUploading.value = false;
    uploadingDocTypeId.value = '';
    super.onClose();
  }

  void loadDocumentTypes() {
    _documentTypesSubscription
        ?.cancel(); // Cancel previous subscription if exists
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

    _candidateDocumentsSubscription
        ?.cancel(); // Cancel previous subscription if exists
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
    final userDocs = candidateDocuments
        .where((doc) => doc.isUserAdded)
        .toList();
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
    return requiredDocumentIds
        .where((docTypeId) => !hasDocument(docTypeId))
        .toList();
  }

  DocumentTypeEntity? getDocumentTypeById(String docTypeId) {
    try {
      return documentTypes.firstWhere(
        (docType) => docType.docTypeId == docTypeId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadDocument(String docTypeId, String docTypeName) async {
    errorMessage.value = '';

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // Validate file
      final validationError = AppFileValidator.validateFile(file);
      if (validationError != null) {
        errorMessage.value = validationError;
        AppSnackbar.error(validationError);
        return;
      }

      final currentUser = authRepository.getCurrentUser();
      if (currentUser == null) {
        errorMessage.value = 'User not authenticated';
        AppSnackbar.error('User not authenticated');
        return;
      }

      // Sanitize document name
      final sanitizedDocTypeName = AppFileValidator.sanitizeFileName(
        docTypeName,
      );
      final sanitizedFileName = AppFileValidator.sanitizeFileName(file.name);
      final documentName =
          '${currentUser.userId}_${sanitizedDocTypeName}_$sanitizedFileName';

      // Reset progress and track which document is being uploaded
      uploadProgress.value = 0.0;
      isUploading.value = true;
      isLoading.value = true;
      uploadingDocTypeId.value = docTypeId;

      // Use the repository implementation directly to access helper method
      final repositoryImpl = documentRepository as DocumentRepositoryImpl;

      final uploadResult = await repositoryImpl.uploadDocumentWithFile(
        candidateId: currentUser.userId,
        docTypeId: docTypeId,
        documentName: documentName,
        platformFile: file,
        onProgress: (progress) {
          uploadProgress.value = progress;
        },
      );

      uploadResult.fold(
        (failure) {
          errorMessage.value = failure.message;
          isLoading.value = false;
          isUploading.value = false;
          uploadProgress.value = 0.0;
          uploadingDocTypeId.value = '';
          AppSnackbar.error(failure.message);
        },
        (document) {
          isLoading.value = false;
          isUploading.value = false;
          uploadProgress.value = 1.0;
          // Reset uploading doc type after a short delay to show completion
          Future.delayed(const Duration(milliseconds: 500), () {
            uploadingDocTypeId.value = '';
            uploadProgress.value = 0.0;
          });
          AppSnackbar.success('Document uploaded successfully');
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to upload file: $e';
      isLoading.value = false;
      isUploading.value = false;
      uploadProgress.value = 0.0;
      AppSnackbar.error('Failed to upload file: $e');
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

      // Validate file
      final validationError = AppFileValidator.validateFile(file);
      if (validationError != null) {
        errorMessage.value = validationError;
        AppSnackbar.error(validationError);
        return;
      }

      selectedFile.value = file;
      selectedFileName.value = file.name;
      selectedFileSize.value = AppFileValidator.formatFileSize(file.size);
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Failed to pick file: $e';
      AppSnackbar.error('Failed to pick file: $e');
    }
  }

  void clearSelectedFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
    selectedFileSize.value = '';
  }

  Future<void> deleteDocument(String candidateDocId, String storageUrl) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await documentRepository.deleteDocument(
        candidateDocId: candidateDocId,
        storageUrl: storageUrl,
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          isLoading.value = false;
          AppSnackbar.error(failure.message);
        },
        (_) {
          isLoading.value = false;
          AppSnackbar.success('Document deleted successfully');
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to delete document: $e';
      isLoading.value = false;
      AppSnackbar.error('Failed to delete document: $e');
    }
  }

  Future<void> createUserDocument({
    required String title,
    required String description,
    DateTime? expiryDate,
    bool hasNoExpiry = false,
  }) async {
    // Validate file is selected
    if (selectedFile.value == null) {
      errorMessage.value = 'Please select a document file';
      AppSnackbar.error('Please select a document file');
      return;
    }

    final file = selectedFile.value!;

    // Validate file again (in case it was changed)
    final validationError = AppFileValidator.validateFile(file);
    if (validationError != null) {
      errorMessage.value = validationError;
      AppSnackbar.error(validationError);
      return;
    }

    errorMessage.value = '';
    uploadProgress.value = 0.0;
    isUploading.value = true;
    isLoading.value = true;

    try {
      final currentUser = authRepository.getCurrentUser();
      if (currentUser == null) {
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        isUploading.value = false;
        uploadProgress.value = 0.0;
        AppSnackbar.error('User not authenticated');
        return;
      }

      // Sanitize title and file name
      final sanitizedTitle = AppFileValidator.sanitizeFileName(title);
      final sanitizedFileName = AppFileValidator.sanitizeFileName(file.name);
      final documentName =
          '${currentUser.userId}_${sanitizedTitle}_$sanitizedFileName';

      // Use the repository implementation directly to access helper method
      final repositoryImpl = documentRepository as DocumentRepositoryImpl;

      final createResult = await repositoryImpl.createUserDocumentWithFile(
        candidateId: currentUser.userId,
        title: title,
        description: description,
        documentName: documentName,
        platformFile: file,
        onProgress: (progress) {
          uploadProgress.value = progress;
        },
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      createResult.fold(
        (failure) {
          errorMessage.value = failure.message;
          isLoading.value = false;
          isUploading.value = false;
          uploadProgress.value = 0.0;
          AppSnackbar.error(failure.message);
        },
        (document) {
          isLoading.value = false;
          isUploading.value = false;
          uploadProgress.value = 1.0;
          clearSelectedFile();
          AppSnackbar.success('Document created successfully');
          // Reset progress after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            uploadProgress.value = 0.0;
          });
          // Navigate to MyDocumentsScreen after successful creation
          Get.offNamed(AppConstants.routeCandidateDocuments);
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to create document: $e';
      isLoading.value = false;
      isUploading.value = false;
      uploadProgress.value = 0.0;
      AppSnackbar.error('Failed to create document: $e');
    }
  }
}
