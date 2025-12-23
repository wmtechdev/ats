import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteJobUseCase {
  final JobRepository repository;

  DeleteJobUseCase(this.repository);

  Future<Either<Failure, void>> call(String jobId) {
    return repository.deleteJob(jobId);
  }
}

