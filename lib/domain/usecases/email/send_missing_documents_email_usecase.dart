import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:dartz/dartz.dart';

class SendMissingDocumentsEmailUseCase {
  final EmailRepository repository;

  SendMissingDocumentsEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String candidateEmail,
    required String candidateName,
    required String jobTitle,
    required List<Map<String, String>> missingDocuments,
  }) {
    return repository.sendMissingDocumentsEmail(
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      jobTitle: jobTitle,
      missingDocuments: missingDocuments,
    );
  }
}
