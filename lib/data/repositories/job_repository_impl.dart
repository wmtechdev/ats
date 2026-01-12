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
        // Handle backward compatibility: if requirements is List, convert to String
        String requirements;
        if (data['requirements'] is List) {
          requirements = (data['requirements'] as List).join(', ');
        } else {
          requirements = data['requirements'] ?? '';
        }

        return JobModel(
          jobId: data['jobId'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          requirements: requirements,
          requiredDocumentIds: List<String>.from(
            data['requiredDocumentIds'] ?? [],
          ),
          status: data['status'] ?? 'open',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

      // Handle backward compatibility
      String requirements;
      if (jobData['requirements'] is List) {
        requirements = (jobData['requirements'] as List).join(', ');
      } else {
        requirements = jobData['requirements'] ?? '';
      }

      final jobModel = JobModel(
        jobId: jobId,
        title: jobData['title'] ?? '',
        description: jobData['description'] ?? '',
        requirements: requirements,
        requiredDocumentIds: List<String>.from(
          jobData['requiredDocumentIds'] ?? [],
        ),
        status: jobData['status'] ?? 'open',
        createdAt:
            (jobData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
        // Handle backward compatibility
        String requirements;
        if (data['requirements'] is List) {
          requirements = (data['requirements'] as List).join(', ');
        } else {
          requirements = data['requirements'] ?? '';
        }

        return JobModel(
          jobId: data['jobId'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          requirements: requirements,
          requiredDocumentIds: List<String>.from(
            data['requiredDocumentIds'] ?? [],
          ),
          status: data['status'] ?? 'open',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, JobEntity>> createJob({
    required String title,
    required String description,
    required String requirements,
    required List<String> requiredDocumentIds,
  }) async {
    try {
      final jobId = await firestoreDataSource.createJob(
        title: title,
        description: description,
        requirements: requirements,
        requiredDocumentIds: requiredDocumentIds,
      );

      final jobData = await firestoreDataSource.getJob(jobId);
      if (jobData == null) {
        return const Left(ServerFailure('Failed to retrieve created job'));
      }

      final jobModel = JobModel(
        jobId: jobId,
        title: jobData['title'] ?? title,
        description: jobData['description'] ?? description,
        requirements: jobData['requirements'] ?? requirements,
        requiredDocumentIds: List<String>.from(
          jobData['requiredDocumentIds'] ?? requiredDocumentIds,
        ),
        status: jobData['status'] ?? 'open',
        createdAt:
            (jobData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
    String? requirements,
    List<String>? requiredDocumentIds,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (requirements != null) updateData['requirements'] = requirements;
      if (requiredDocumentIds != null) {
        updateData['requiredDocumentIds'] = requiredDocumentIds;
      }
      if (status != null) updateData['status'] = status;

      await firestoreDataSource.updateJob(jobId: jobId, data: updateData);

      final jobData = await firestoreDataSource.getJob(jobId);
      if (jobData == null) {
        return const Left(ServerFailure('Failed to retrieve updated job'));
      }

      // Handle backward compatibility
      String reqs;
      if (jobData['requirements'] is List) {
        reqs = (jobData['requirements'] as List).join(', ');
      } else {
        reqs = jobData['requirements'] ?? '';
      }

      final jobModel = JobModel(
        jobId: jobId,
        title: jobData['title'] ?? '',
        description: jobData['description'] ?? '',
        requirements: reqs,
        requiredDocumentIds: List<String>.from(
          jobData['requiredDocumentIds'] ?? [],
        ),
        status: jobData['status'] ?? 'open',
        createdAt:
            (jobData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
