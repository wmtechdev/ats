import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for candidate sign in
class CandidateSignInUseCase {
  final CandidateAuthRepository repository;

  CandidateSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(
      email: email,
      password: password,
    );
  }
}

