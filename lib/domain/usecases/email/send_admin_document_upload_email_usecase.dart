import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendAdminDocumentUploadEmailUseCase {
  final EmailRepository repository;

  SendAdminDocumentUploadEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) {
    return repository.sendAdminDocumentUploadEmail(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: documentName,
    );
  }
}
