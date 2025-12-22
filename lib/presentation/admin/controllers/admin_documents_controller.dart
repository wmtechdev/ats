import 'package:get/get.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/document_type_entity.dart';

class AdminDocumentsController extends GetxController {
  final DocumentRepository documentRepository;

  AdminDocumentsController(this.documentRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final documentTypes = <DocumentTypeEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDocumentTypes();
  }

  void loadDocumentTypes() {
    documentRepository.streamDocumentTypes().listen((types) {
      documentTypes.value = types;
    });
  }

  Future<void> createDocumentType({
    required String name,
    required String description,
    required bool isRequired,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await documentRepository.createDocumentType(
      name: name,
      description: description,
      isRequired: isRequired,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (docType) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document type created successfully');
        Get.back();
      },
    );
  }

  Future<void> updateDocumentType({
    required String docTypeId,
    String? name,
    String? description,
    bool? isRequired,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await documentRepository.updateDocumentType(
      docTypeId: docTypeId,
      name: name,
      description: description,
      isRequired: isRequired,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (docType) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document type updated successfully');
        Get.back();
      },
    );
  }

  Future<void> deleteDocumentType(String docTypeId) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await documentRepository.deleteDocumentType(docTypeId);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document type deleted successfully');
      },
    );
  }
}

