import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:dartz/dartz.dart';

abstract class DocumentRepository {
  // Document Types
  Future<Either<Failure, List<DocumentTypeEntity>>> getDocumentTypes();

  Stream<List<DocumentTypeEntity>> streamDocumentTypes();

  Future<Either<Failure, DocumentTypeEntity>> createDocumentType({
    required String name,
    required String description,
    required bool isRequired,
  });

  Future<Either<Failure, DocumentTypeEntity>> updateDocumentType({
    required String docTypeId,
    String? name,
    String? description,
    bool? isRequired,
  });

  Future<Either<Failure, void>> deleteDocumentType(String docTypeId);

  // Candidate Documents
  Future<Either<Failure, CandidateDocumentEntity>> uploadDocument({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required String filePath,
  });

  Future<Either<Failure, CandidateDocumentEntity>> createUserDocument({
    required String candidateId,
    required String title,
    required String description,
    required String documentName,
    required String filePath,
  });

  Future<Either<Failure, List<CandidateDocumentEntity>>> getCandidateDocuments(
    String candidateId,
  );

  Stream<List<CandidateDocumentEntity>> streamCandidateDocuments(
    String candidateId,
  );

  Future<Either<Failure, CandidateDocumentEntity>> updateDocumentStatus({
    required String candidateDocId,
    required String status,
  });
}

