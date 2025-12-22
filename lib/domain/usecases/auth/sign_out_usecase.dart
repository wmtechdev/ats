import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}

