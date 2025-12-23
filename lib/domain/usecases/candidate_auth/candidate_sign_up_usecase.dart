import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for candidate sign up
class CandidateSignUpUseCase {
  final CandidateAuthRepository repository;

  CandidateSignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? address,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
    );
  }
}

