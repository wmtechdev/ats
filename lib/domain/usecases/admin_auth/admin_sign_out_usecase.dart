import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/admin_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for admin sign out
class AdminSignOutUseCase {
  final AdminAuthRepository repository;

  AdminSignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}

