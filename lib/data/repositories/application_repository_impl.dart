import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/models/application_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirestoreDataSource firestoreDataSource;

  ApplicationRepositoryImpl(this.firestoreDataSource);

  @override
  Future<Either<Failure, ApplicationEntity>> createApplication({
    required String candidateId,
    required String jobId,
  }) async {
    try {
      final applicationId = await firestoreDataSource.createApplication(
        candidateId: candidateId,
        jobId: jobId,
      );

      final app = ApplicationModel(
        applicationId: applicationId,
        candidateId: candidateId,
        jobId: jobId,
        status: AppConstants.applicationStatusPending,
        appliedAt: DateTime.now(),
      );

      return Right(app.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getApplications({
    String? candidateId,
    String? jobId,
    String? status,
  }) async {
    try {
      final appsData = await firestoreDataSource.getApplications(
        candidateId: candidateId,
        jobId: jobId,
        status: status,
      );
      final apps = appsData.map((data) {
        return ApplicationModel(
          applicationId: '', // This needs to be fixed
          candidateId: data['candidateId'] ?? '',
          jobId: data['jobId'] ?? '',
          status: data['status'] ?? AppConstants.applicationStatusPending,
          appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ).toEntity();
      }).toList();
      return Right(apps);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<List<ApplicationEntity>> streamApplications({
    String? candidateId,
    String? jobId,
    String? status,
  }) {
    return firestoreDataSource.streamApplications(
      candidateId: candidateId,
      jobId: jobId,
      status: status,
    ).map((appsData) {
      return appsData.map((data) {
        return ApplicationModel(
          applicationId: '', // This needs to be fixed
          candidateId: data['candidateId'] ?? '',
          jobId: data['jobId'] ?? '',
          status: data['status'] ?? AppConstants.applicationStatusPending,
          appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, ApplicationEntity>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await firestoreDataSource.updateApplication(
        applicationId: applicationId,
        data: {'status': status},
      );

      // Note: We'd need to get the updated application
      final app = ApplicationModel(
        applicationId: applicationId,
        candidateId: '',
        jobId: '',
        status: status,
        appliedAt: DateTime.now(),
      );

      return Right(app.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}

