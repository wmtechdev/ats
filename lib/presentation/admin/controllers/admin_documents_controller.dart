import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/document_type_entity.dart';

class AdminDocumentsController extends GetxController {
  final DocumentRepository documentRepository;

  AdminDocumentsController(this.documentRepository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final documentTypes = <DocumentTypeEntity>[].obs;
  final filteredDocumentTypes = <DocumentTypeEntity>[].obs;
  final searchQuery = ''.obs;

  // Stream subscription
  StreamSubscription<List<DocumentTypeEntity>>? _documentTypesSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDocumentTypes();
  }

  @override
  void onClose() {
    // Cancel stream subscription to prevent permission errors after sign-out
    _documentTypesSubscription?.cancel();
    super.onClose();
  }

  void loadDocumentTypes() {
    _documentTypesSubscription?.cancel(); // Cancel previous subscription if exists
    _documentTypesSubscription = documentRepository.streamDocumentTypes().listen(
      (types) {
        documentTypes.value = types;
        _applyFilters();
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<DocumentTypeEntity>.from(documentTypes);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((docType) =>
              docType.name.toLowerCase().contains(query) ||
              docType.description.toLowerCase().contains(query))
          .toList();
    }

    filteredDocumentTypes.value = filtered;
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
        Get.offNamedUntil(
          AppConstants.routeAdminDocumentTypes,
          (route) => route.settings.name == AppConstants.routeAdminDocumentTypes,
        );
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
        Get.offNamedUntil(
          AppConstants.routeAdminDocumentTypes,
          (route) => route.settings.name == AppConstants.routeAdminDocumentTypes,
        );
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

