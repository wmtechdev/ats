import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:dartz/dartz.dart';

class UploadDocumentUseCase {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, CandidateDocumentEntity>> call({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required String filePath,
  }) {
    return repository.uploadDocument(
      candidateId: candidateId,
      docTypeId: docTypeId,
      documentName: documentName,
      filePath: filePath,
    );
  }
}

