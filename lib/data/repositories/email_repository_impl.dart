import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/data/data_sources/firebase_functions_data_source.dart';
import 'package:dartz/dartz.dart';

class EmailRepositoryImpl implements EmailRepository {
  final FirebaseFunctionsDataSource functionsDataSource;

  EmailRepositoryImpl({
    required this.functionsDataSource,
  });

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
}

