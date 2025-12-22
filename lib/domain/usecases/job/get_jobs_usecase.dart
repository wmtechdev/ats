import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:dartz/dartz.dart';

class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  Future<Either<Failure, List<JobEntity>>> call({String? status}) {
    return repository.getJobs(status: status);
  }
}

