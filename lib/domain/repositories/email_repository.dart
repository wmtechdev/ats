import 'package:ats/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class EmailRepository {
  /// Sends a document denial email to a candidate
  Future<Either<Failure, void>> sendDocumentDenialEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
  });

  /// Sends a document request email to a candidate
  Future<Either<Failure, void>> sendDocumentRequestEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    required String documentDescription,
  });

  /// Sends a document request revocation email to a candidate
  Future<Either<Failure, void>> sendDocumentRequestRevocationEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  });

  /// Sends an email notification to a candidate when admin uploads a document on their behalf
  Future<Either<Failure, void>> sendAdminDocumentUploadEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  });

  /// Sends a missing documents email to a candidate when they apply for a job
  Future<Either<Failure, void>> sendMissingDocumentsEmail({
    required String candidateEmail,
    required String candidateName,
    required String jobTitle,
    required List<Map<String, String>> missingDocuments,
  });
}
