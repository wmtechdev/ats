import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:dartz/dartz.dart';

class CreateApplicationUseCase {
  final ApplicationRepository repository;

  CreateApplicationUseCase(this.repository);

  Future<Either<Failure, ApplicationEntity>> call({
    required String candidateId,
    required String jobId,
  }) {
    return repository.createApplication(
      candidateId: candidateId,
      jobId: jobId,
    );
  }
}

