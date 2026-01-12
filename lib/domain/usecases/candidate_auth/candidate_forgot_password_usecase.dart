import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for candidate forgot password
class CandidateForgotPasswordUseCase {
  final CandidateAuthRepository repository;

  CandidateForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}
