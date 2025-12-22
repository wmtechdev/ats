import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateDocumentStatusUseCase {
  final DocumentRepository repository;

  UpdateDocumentStatusUseCase(this.repository);

  Future<Either<Failure, CandidateDocumentEntity>> call({
    required String candidateDocId,
    required String status,
  }) {
    return repository.updateDocumentStatus(
      candidateDocId: candidateDocId,
      status: status,
    );
  }
}

