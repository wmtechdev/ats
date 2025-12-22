import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class JobRepositoryImpl implements JobRepository {
  final FirestoreDataSource firestoreDataSource;

  JobRepositoryImpl(this.firestoreDataSource);

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs({String? status}) async {
    try {
      final jobsData = await firestoreDataSource.getJobs(status: status);
      final jobs = jobsData.map((data) {
        // We need jobId from the document, but our data source doesn't return it
        // This is a limitation - we need to fix the data source
        return JobModel(
          jobId: '', // This needs to be fixed
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          hospitalName: data['hospitalName'] ?? '',
          requirements: List<String>.from(data['requirements'] ?? []),
          status: data['status'] ?? 'open',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ).toEntity();
      }).toList();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJob(String jobId) async {
    try {
      final jobData = await firestoreDataSource.getJob(jobId);
      if (jobData == null) {
        return const Left(ServerFailure('Job not found'));
      }

      final jobModel = JobModel(
        jobId: jobId,
        title: jobData['title'] ?? '',
        description: jobData['description'] ?? '',
        hospitalName: jobData['hospitalName'] ?? '',
        requirements: List<String>.from(jobData['requirements'] ?? []),
        status: jobData['status'] ?? 'open',
        createdAt: (jobData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<List<JobEntity>> streamJobs({String? status}) {
    return firestoreDataSource.streamJobs(status: status).map((jobsData) {
      return jobsData.map((data) {
        return JobModel(
          jobId: '', // This needs to be fixed
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          hospitalName: data['hospitalName'] ?? '',
          requirements: List<String>.from(data['requirements'] ?? []),
          status: data['status'] ?? 'open',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, JobEntity>> createJob({
    required String title,
    required String description,
    required String hospitalName,
    required List<String> requirements,
  }) async {
    try {
      final jobId = await firestoreDataSource.createJob(
        title: title,
        description: description,
        hospitalName: hospitalName,
        requirements: requirements,
      );

      final jobData = await firestoreDataSource.getJob(jobId);
      if (jobData == null) {
        return const Left(ServerFailure('Failed to retrieve created job'));
      }

      final jobModel = JobModel(
        jobId: jobId,
        title: jobData['title'] ?? title,
        description: jobData['description'] ?? description,
        hospitalName: jobData['hospitalName'] ?? hospitalName,
        requirements: List<String>.from(jobData['requirements'] ?? requirements),
        status: jobData['status'] ?? 'open',
        createdAt: (jobData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? hospitalName,
    List<String>? requirements,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (hospitalName != null) updateData['hospitalName'] = hospitalName;
      if (requirements != null) updateData['requirements'] = requirements;
      if (status != null) updateData['status'] = status;

      await firestoreDataSource.updateJob(
        jobId: jobId,
        data: updateData,
      );

      final jobData = await firestoreDataSource.getJob(jobId);
      if (jobData == null) {
        return const Left(ServerFailure('Failed to retrieve updated job'));
      }

      final jobModel = JobModel(
        jobId: jobId,
        title: jobData['title'] ?? '',
        description: jobData['description'] ?? '',
        hospitalName: jobData['hospitalName'] ?? '',
        requirements: List<String>.from(jobData['requirements'] ?? []),
        status: jobData['status'] ?? 'open',
        createdAt: (jobData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      return Right(jobModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteJob(String jobId) async {
    try {
      await firestoreDataSource.deleteJob(jobId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}

