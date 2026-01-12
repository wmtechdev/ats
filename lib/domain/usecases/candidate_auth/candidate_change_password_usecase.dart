import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for candidate change password
class CandidateChangePasswordUseCase {
  final CandidateAuthRepository repository;

  CandidateChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
