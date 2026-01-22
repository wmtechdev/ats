import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/data/data_sources/firebase_functions_data_source.dart';
import 'package:dartz/dartz.dart';

class EmailRepositoryImpl implements EmailRepository {
  final FirebaseFunctionsDataSource functionsDataSource;

  EmailRepositoryImpl({required this.functionsDataSource});

  @override
  Future<Either<Failure, void>> sendDocumentDenialEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
  }) async {
    try {
      await functionsDataSource.sendDocumentDenialEmail(
        candidateEmail: candidateEmail,
        candidateName: candidateName,
        documentName: documentName,
        denialReason: denialReason,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendDocumentRequestEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    required String documentDescription,
  }) async {
    try {
      await functionsDataSource.sendDocumentRequestEmail(
        candidateEmail: candidateEmail,
        candidateName: candidateName,
        documentName: documentName,
        documentDescription: documentDescription,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendDocumentRequestRevocationEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) async {
    try {
      await functionsDataSource.sendDocumentRequestRevocationEmail(
        candidateEmail: candidateEmail,
        candidateName: candidateName,
        documentName: documentName,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendAdminDocumentUploadEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) async {
    try {
      await functionsDataSource.sendAdminDocumentUploadEmail(
        candidateEmail: candidateEmail,
        candidateName: candidateName,
        documentName: documentName,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendMissingDocumentsEmail({
    required String candidateEmail,
    required String candidateName,
    required String jobTitle,
    required List<Map<String, String>> missingDocuments,
  }) async {
    try {
      await functionsDataSource.sendMissingDocumentsEmail(
        candidateEmail: candidateEmail,
        candidateName: candidateName,
        jobTitle: jobTitle,
        missingDocuments: missingDocuments,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
