import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:dartz/dartz.dart';

abstract class JobRepository {
  Future<Either<Failure, List<JobEntity>>> getJobs({String? status});

  Future<Either<Failure, JobEntity>> getJob(String jobId);

  Stream<List<JobEntity>> streamJobs({String? status});

  Future<Either<Failure, JobEntity>> createJob({
    required String title,
    required String description,
    required String hospitalName,
    required List<String> requirements,
  });

  Future<Either<Failure, JobEntity>> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? hospitalName,
    List<String>? requirements,
    String? status,
  });

  Future<Either<Failure, void>> deleteJob(String jobId);
}

