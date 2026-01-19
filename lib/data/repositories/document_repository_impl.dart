import 'dart:io';
import 'dart:typed_data';
import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/data/models/document_type_model.dart';
import 'package:ats/data/models/candidate_document_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DocumentRepositoryImpl implements DocumentRepository {
  final FirestoreDataSource firestoreDataSource;
  final FirebaseStorageDataSource storageDataSource;

  DocumentRepositoryImpl({
    required this.firestoreDataSource,
    required this.storageDataSource,
  });

  @override
  Future<Either<Failure, List<DocumentTypeEntity>>> getDocumentTypes() async {
    try {
      final docsData = await firestoreDataSource.getDocumentTypes();
      final docs = docsData
          .where((data) {
            // Filter out candidate-specific documents for admin view
            final isCandidateSpecific = data['isCandidateSpecific'] ?? false;
            return !isCandidateSpecific;
          })
          .map((data) {
            return DocumentTypeModel(
              docTypeId: data['docTypeId'] ?? '',
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              isRequired: data['isRequired'] ?? false,
              isCandidateSpecific: data['isCandidateSpecific'] ?? false,
              requestedForCandidateId:
                  data['requestedForCandidateId'] as String?,
              requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
            ).toEntity();
          })
          .toList();
      return Right(docs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<List<DocumentTypeEntity>> streamDocumentTypes() {
    return firestoreDataSource.streamDocumentTypes().map((docsData) {
      return docsData
          .where((data) {
            // Filter out candidate-specific documents for admin view
            final isCandidateSpecific = data['isCandidateSpecific'] ?? false;
            return !isCandidateSpecific;
          })
          .map((data) {
            return DocumentTypeModel(
              docTypeId: data['docTypeId'] ?? '',
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              isRequired: data['isRequired'] ?? false,
              isCandidateSpecific: data['isCandidateSpecific'] ?? false,
              requestedForCandidateId:
                  data['requestedForCandidateId'] as String?,
              requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
            ).toEntity();
          })
          .toList();
    });
  }

  /// Stream document types for a specific candidate (includes candidate-specific ones)
  Stream<List<DocumentTypeEntity>> streamDocumentTypesForCandidate(
    String candidateId,
  ) {
    return firestoreDataSource
        .streamDocumentTypesForCandidate(candidateId)
        .map((docsData) {
      return docsData.map((data) {
        return DocumentTypeModel(
          docTypeId: data['docTypeId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          isRequired: data['isRequired'] ?? false,
          isCandidateSpecific: data['isCandidateSpecific'] ?? false,
          requestedForCandidateId: data['requestedForCandidateId'] as String?,
          requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
        ).toEntity();
      }).toList();
    });
  }

  /// Get candidate-specific document types for a candidate
  Future<List<Map<String, dynamic>>> getCandidateSpecificDocumentTypes(
    String candidateId,
  ) async {
    try {
      return await firestoreDataSource.getCandidateSpecificDocumentTypes(
        candidateId,
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Either<Failure, DocumentTypeEntity>> createDocumentType({
    required String name,
    required String description,
    required bool isRequired,
  }) async {
    try {
      final docTypeId = await firestoreDataSource.createDocumentType(
        name: name,
        description: description,
        isRequired: isRequired,
      );

      // Note: We'd need to get the created document to return it properly
      final docType = DocumentTypeModel(
        docTypeId: docTypeId,
        name: name,
        description: description,
        isRequired: isRequired,
      );

      return Right(docType.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  /// Create a candidate-specific document type
  Future<Either<Failure, DocumentTypeEntity>> createCandidateSpecificDocumentType({
    required String name,
    required String description,
    required String candidateId,
  }) async {
    try {
      final docTypeId = await firestoreDataSource.createDocumentType(
        name: name,
        description: description,
        isRequired: false, // Requested documents are optional
        isCandidateSpecific: true,
        requestedForCandidateId: candidateId,
        requestedAt: DateTime.now(),
      );

      final docType = DocumentTypeModel(
        docTypeId: docTypeId,
        name: name,
        description: description,
        isRequired: false,
        isCandidateSpecific: true,
        requestedForCandidateId: candidateId,
        requestedAt: DateTime.now(),
      );

      return Right(docType.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentTypeEntity>> updateDocumentType({
    required String docTypeId,
    String? name,
    String? description,
    bool? isRequired,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isRequired != null) updateData['isRequired'] = isRequired;

      await firestoreDataSource.updateDocumentType(
        docTypeId: docTypeId,
        data: updateData,
      );

      // Note: We'd need to get the updated document
      final docType = DocumentTypeModel(
        docTypeId: docTypeId,
        name: name ?? '',
        description: description ?? '',
        isRequired: isRequired ?? false,
      );

      return Right(docType.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocumentType(String docTypeId) async {
    try {
      await firestoreDataSource.deleteDocumentType(docTypeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CandidateDocumentEntity>> uploadDocument({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required String filePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      File? file;
      Uint8List? bytes;
      String? mimeType;

      if (kIsWeb) {
        // Web: filePath is not available, need to get bytes from PlatformFile
        // This method will be called with filePath, but for web we need bytes
        // The actual file handling should be done in the controller
        return const Left(
          StorageFailure(
            'Web platform requires file bytes. Use uploadDocumentWithFile method instead.',
          ),
        );
      } else {
        // Mobile: use File
        file = File(filePath);
        if (!await file.exists()) {
          return const Left(StorageFailure('File does not exist'));
        }
      }

      // Sanitize file name
      final sanitizedFileName = AppFileValidator.sanitizeFileName(documentName);

      // Upload to Firebase Storage
      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.documentsStoragePath}/$candidateId',
        fileName: sanitizedFileName,
        file: file,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );

      // Create document record in Firestore
      final candidateDocId = await firestoreDataSource.createCandidateDocument(
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
      );

      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        status: AppConstants.documentStatusPending,
        uploadedAt: DateTime.now(),
        hasNoExpiry: false,
      );

      return Right(doc.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('An unexpected error occurred: $e'));
    }
  }

  /// Helper method to upload document with PlatformFile (supports both web and mobile)
  Future<Either<Failure, CandidateDocumentEntity>> uploadDocumentWithFile({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required PlatformFile platformFile,
    void Function(double progress)? onProgress,
    DateTime? expiryDate,
    bool hasNoExpiry = false,
  }) async {
    try {
      // Validate file
      final validationError = AppFileValidator.validateFile(platformFile);
      if (validationError != null) {
        return Left(StorageFailure(validationError));
      }

      // Before uploading, delete any previous denied documents with the same docTypeId
      try {
        final allDocs = await firestoreDataSource.getCandidateDocuments(
          candidateId,
        );
        final deniedDocs = allDocs.where((doc) {
          return doc['docTypeId'] == docTypeId &&
              doc['status'] == AppConstants.documentStatusDenied;
        }).toList();

        // Delete all denied documents for this docTypeId
        for (final deniedDoc in deniedDocs) {
          final deniedDocId = deniedDoc['candidateDocId'] as String;
          final deniedStorageUrl = deniedDoc['storageUrl'] as String? ?? '';

          // Delete from storage first
          if (deniedStorageUrl.isNotEmpty) {
            try {
              await storageDataSource.deleteFileByUrl(deniedStorageUrl);
            } catch (e) {
              // Continue - storage deletion failure shouldn't block reupload
            }
          }

          // Delete from Firestore
          await firestoreDataSource.deleteCandidateDocument(deniedDocId);
        }
      } catch (e) {
        // Continue - deletion of old documents shouldn't block new upload
      }

      File? file;
      Uint8List? bytes;
      String? mimeType;

      if (kIsWeb) {
        // Web: use bytes
        if (platformFile.bytes == null) {
          return const Left(
            StorageFailure('File bytes are required for web platform'),
          );
        }
        bytes = platformFile.bytes;
      } else {
        // Mobile: use File
        if (platformFile.path == null) {
          return const Left(
            StorageFailure('File path is required for mobile platform'),
          );
        }
        file = File(platformFile.path!);
        if (!await file.exists()) {
          return const Left(StorageFailure('File does not exist'));
        }
      }

      // Get MIME type from extension
      if (platformFile.extension != null) {
        mimeType = _getMimeTypeFromExtension(platformFile.extension!);
      }

      // Sanitize file name
      final sanitizedFileName = AppFileValidator.sanitizeFileName(documentName);

      // Upload to Firebase Storage
      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.documentsStoragePath}/$candidateId',
        fileName: sanitizedFileName,
        file: file,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );

      // Create document record in Firestore
      final candidateDocId = await firestoreDataSource.createCandidateDocument(
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        status: AppConstants.documentStatusPending,
        uploadedAt: DateTime.now(),
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      return Right(doc.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('An unexpected error occurred: $e'));
    }
  }

  /// Helper method to get MIME type from file extension
  String? _getMimeTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';
      case 'odt':
        return 'application/vnd.oasis.opendocument.text';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }

  @override
  Future<Either<Failure, CandidateDocumentEntity>> createUserDocument({
    required String candidateId,
    required String title,
    required String description,
    required String documentName,
    required String filePath,
    void Function(double progress)? onProgress,
    DateTime? expiryDate,
    bool hasNoExpiry = false,
  }) async {
    try {
      File? file;
      Uint8List? bytes;
      String? mimeType;

      if (kIsWeb) {
        // Web: filePath is not available, need to get bytes from PlatformFile
        return const Left(
          StorageFailure(
            'Web platform requires file bytes. Use createUserDocumentWithFile method instead.',
          ),
        );
      } else {
        // Mobile: use File
        file = File(filePath);
        if (!await file.exists()) {
          return const Left(StorageFailure('File does not exist'));
        }
      }

      // Sanitize file name
      final sanitizedFileName = AppFileValidator.sanitizeFileName(documentName);

      // Upload to Firebase Storage
      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.documentsStoragePath}/$candidateId',
        fileName: sanitizedFileName,
        file: file,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );

      // Create document record in Firestore with empty docTypeId to indicate user-added document
      final candidateDocId = await firestoreDataSource.createCandidateDocument(
        candidateId: candidateId,
        docTypeId: '', // Empty docTypeId indicates user-added document
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        title: title,
        description: description,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: candidateId,
        docTypeId: '', // Empty docTypeId indicates user-added document
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        status: AppConstants.documentStatusPending,
        uploadedAt: DateTime.now(),
        title: title,
        description: description,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      return Right(doc.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('An unexpected error occurred: $e'));
    }
  }

  /// Helper method to create user document with PlatformFile (supports both web and mobile)
  Future<Either<Failure, CandidateDocumentEntity>> createUserDocumentWithFile({
    required String candidateId,
    required String title,
    required String description,
    required String documentName,
    required PlatformFile platformFile,
    void Function(double progress)? onProgress,
    DateTime? expiryDate,
    bool hasNoExpiry = false,
  }) async {
    try {
      // Validate file
      final validationError = AppFileValidator.validateFile(platformFile);
      if (validationError != null) {
        return Left(StorageFailure(validationError));
      }

      File? file;
      Uint8List? bytes;
      String? mimeType;

      if (kIsWeb) {
        // Web: use bytes
        if (platformFile.bytes == null) {
          return const Left(
            StorageFailure('File bytes are required for web platform'),
          );
        }
        bytes = platformFile.bytes;
      } else {
        // Mobile: use File
        if (platformFile.path == null) {
          return const Left(
            StorageFailure('File path is required for mobile platform'),
          );
        }
        file = File(platformFile.path!);
        if (!await file.exists()) {
          return const Left(StorageFailure('File does not exist'));
        }
      }

      // Get MIME type from extension
      if (platformFile.extension != null) {
        mimeType = _getMimeTypeFromExtension(platformFile.extension!);
      }

      // Sanitize file name
      final sanitizedFileName = AppFileValidator.sanitizeFileName(documentName);

      // Upload to Firebase Storage
      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.documentsStoragePath}/$candidateId',
        fileName: sanitizedFileName,
        file: file,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );

      // Create document record in Firestore with empty docTypeId to indicate user-added document
      final candidateDocId = await firestoreDataSource.createCandidateDocument(
        candidateId: candidateId,
        docTypeId: '', // Empty docTypeId indicates user-added document
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        title: title,
        description: description,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: candidateId,
        docTypeId: '', // Empty docTypeId indicates user-added document
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        status: AppConstants.documentStatusPending,
        uploadedAt: DateTime.now(),
        title: title,
        description: description,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      return Right(doc.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CandidateDocumentEntity>>> getCandidateDocuments(
    String candidateId,
  ) async {
    try {
      final docsData = await firestoreDataSource.getCandidateDocuments(
        candidateId,
      );
      final docs = docsData.map((data) {
        return CandidateDocumentModel(
          candidateDocId: data['candidateDocId'] ?? '',
          candidateId: data['candidateId'] ?? candidateId,
          docTypeId: data['docTypeId'] ?? '',
          documentName: data['documentName'] ?? '',
          storageUrl: data['storageUrl'] ?? '',
          status: data['status'] ?? AppConstants.documentStatusPending,
          uploadedAt:
              (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          title: data['title'] as String?,
          description: data['description'] as String?,
          expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
          hasNoExpiry: data['hasNoExpiry'] ?? false,
        ).toEntity();
      }).toList();
      return Right(docs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<List<CandidateDocumentEntity>> streamCandidateDocuments(
    String candidateId,
  ) {
    return firestoreDataSource.streamCandidateDocuments(candidateId).map((
      docsData,
    ) {
      return docsData.map((data) {
        return CandidateDocumentModel(
          candidateDocId: data['candidateDocId'] ?? '',
          candidateId: data['candidateId'] ?? candidateId,
          docTypeId: data['docTypeId'] ?? '',
          documentName: data['documentName'] ?? '',
          storageUrl: data['storageUrl'] ?? '',
          status: data['status'] ?? AppConstants.documentStatusPending,
          uploadedAt:
              (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          title: data['title'] as String?,
          description: data['description'] as String?,
          expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
          hasNoExpiry: data['hasNoExpiry'] ?? false,
        ).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, CandidateDocumentEntity>> updateDocumentStatus({
    required String candidateDocId,
    required String status,
  }) async {
    try {
      await firestoreDataSource.updateCandidateDocument(
        candidateDocId: candidateDocId,
        data: {'status': status},
      );

      // Note: We'd need to get the updated document
      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: '',
        docTypeId: '',
        documentName: '',
        storageUrl: '',
        status: status,
        uploadedAt: DateTime.now(),
        hasNoExpiry: false,
      );

      return Right(doc.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument({
    required String candidateDocId,
    required String storageUrl,
  }) async {
    // First, try to delete from Firebase Storage
    // Use the download URL directly for more reliable deletion
    try {
      await storageDataSource.deleteFileByUrl(storageUrl);
    } on StorageException {
      // Continue with Firestore deletion even if storage deletion fails
      // This ensures the document record is removed even if file deletion fails
    } catch (_) {
      // Continue - unexpected errors shouldn't block Firestore deletion
    }

    // Always delete from Firestore, even if storage deletion failed
    // This ensures data consistency and triggers the stream update
    try {
      await firestoreDataSource.deleteCandidateDocument(candidateDocId);
    } on ServerException catch (e) {
      // If Firestore deletion fails, return the error
      return Left(ServerFailure(e.message));
    }

    // If storage deletion failed but Firestore deletion succeeded,
    // return success (document is removed from database)
    // The file might still exist in storage, but the document record is gone
    return const Right(null);
  }

  @override
  Future<Either<Failure, CandidateDocumentEntity>> createDocumentForAdmin({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required PlatformFile platformFile,
    required String title,
    void Function(double progress)? onProgress,
    DateTime? expiryDate,
    bool hasNoExpiry = false,
  }) async {
    try {
      // Validate file
      final validationError = AppFileValidator.validateFile(platformFile);
      if (validationError != null) {
        return Left(StorageFailure(validationError));
      }

      File? file;
      Uint8List? bytes;
      String? mimeType;

      if (kIsWeb) {
        // Web: use bytes
        if (platformFile.bytes == null) {
          return const Left(
            StorageFailure('File bytes are required for web platform'),
          );
        }
        bytes = platformFile.bytes;
      } else {
        // Mobile: use File
        if (platformFile.path == null) {
          return const Left(
            StorageFailure('File path is required for mobile platform'),
          );
        }
        file = File(platformFile.path!);
        if (!await file.exists()) {
          return const Left(StorageFailure('File does not exist'));
        }
      }

      // Get MIME type from extension
      if (platformFile.extension != null) {
        mimeType = _getMimeTypeFromExtension(platformFile.extension!);
      }

      // Sanitize file name
      final sanitizedFileName = AppFileValidator.sanitizeFileName(documentName);

      // Upload to Firebase Storage
      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.documentsStoragePath}/$candidateId',
        fileName: sanitizedFileName,
        file: file,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );

      // Create document record in Firestore with approved status
      final candidateDocId = await firestoreDataSource.createCandidateDocument(
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        title: title,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
        status: AppConstants.documentStatusApproved, // Admin uploads are approved by default
      );

      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: sanitizedFileName,
        storageUrl: downloadUrl,
        status: AppConstants.documentStatusApproved,
        uploadedAt: DateTime.now(),
        title: title,
        expiryDate: expiryDate,
        hasNoExpiry: hasNoExpiry,
      );

      return Right(doc.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('An unexpected error occurred: $e'));
    }
  }
}
