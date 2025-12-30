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
}

