import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateJobUseCase {
  final JobRepository repository;

  UpdateJobUseCase(this.repository);

  Future<Either<Failure, JobEntity>> call({
    required String jobId,
    String? title,
    String? description,
    String? requirements,
    List<String>? requiredDocumentIds,
    String? status,
  }) {
    return repository.updateJob(
      jobId: jobId,
      title: title,
      description: description,
      requirements: requirements,
      requiredDocumentIds: requiredDocumentIds,
      status: status,
    );
  }
}
