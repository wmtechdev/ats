import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/admin_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for admin sign in
class AdminSignInUseCase {
  final AdminAuthRepository repository;

  AdminSignInUseCase(this.repository);

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

