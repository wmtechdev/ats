import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateApplicationStatusUseCase {
  final ApplicationRepository repository;

  UpdateApplicationStatusUseCase(this.repository);

  Future<Either<Failure, ApplicationEntity>> call({
    required String applicationId,
    required String status,
  }) {
    return repository.updateApplicationStatus(
      applicationId: applicationId,
      status: status,
    );
  }
}

