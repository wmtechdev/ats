import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for candidate sign out
class CandidateSignOutUseCase {
  final CandidateAuthRepository repository;

  CandidateSignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}

