import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendDocumentDenialEmailUseCase {
  final EmailRepository repository;

  SendDocumentDenialEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
  }) {
    return repository.sendDocumentDenialEmail(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      documentName: documentName,
      denialReason: denialReason,
    );
  }
}

