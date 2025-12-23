import 'dart:io';
import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/data/models/document_type_model.dart';
import 'package:ats/data/models/candidate_document_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

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
      final docs = docsData.map((data) {
        return DocumentTypeModel(
          docTypeId: data['docTypeId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          isRequired: data['isRequired'] ?? false,
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
  Stream<List<DocumentTypeEntity>> streamDocumentTypes() {
    return firestoreDataSource.streamDocumentTypes().map((docsData) {
      return docsData.map((data) {
        return DocumentTypeModel(
          docTypeId: data['docTypeId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          isRequired: data['isRequired'] ?? false,
        ).toEntity();
      }).toList();
    });
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
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Left(StorageFailure('File does not exist'));
      }

      // Upload to Firebase Storage
      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.documentsStoragePath}/$candidateId',
        fileName: documentName,
        file: file,
      );

      // Create document record in Firestore
      final candidateDocId = await firestoreDataSource.createCandidateDocument(
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: documentName,
        storageUrl: downloadUrl,
      );

      final doc = CandidateDocumentModel(
        candidateDocId: candidateDocId,
        candidateId: candidateId,
        docTypeId: docTypeId,
        documentName: documentName,
        storageUrl: downloadUrl,
        status: AppConstants.documentStatusPending,
        uploadedAt: DateTime.now(),
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
      final docsData = await firestoreDataSource.getCandidateDocuments(candidateId);
      final docs = docsData.map((data) {
        return CandidateDocumentModel(
          candidateDocId: '', // This needs to be fixed
          candidateId: data['candidateId'] ?? candidateId,
          docTypeId: data['docTypeId'] ?? '',
          documentName: data['documentName'] ?? '',
          storageUrl: data['storageUrl'] ?? '',
          status: data['status'] ?? AppConstants.documentStatusPending,
          uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
    return firestoreDataSource.streamCandidateDocuments(candidateId).map((docsData) {
      return docsData.map((data) {
        return CandidateDocumentModel(
          candidateDocId: '', // This needs to be fixed
          candidateId: data['candidateId'] ?? candidateId,
          docTypeId: data['docTypeId'] ?? '',
          documentName: data['documentName'] ?? '',
          storageUrl: data['storageUrl'] ?? '',
          status: data['status'] ?? AppConstants.documentStatusPending,
          uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      );

      return Right(doc.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}

