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
    required List<String> requiredDocumentIds,
  }) async {
    try {
      final applicationId = await firestoreDataSource.createApplication(
        candidateId: candidateId,
        jobId: jobId,
        requiredDocumentIds: requiredDocumentIds,
      );

      final app = ApplicationModel(
        applicationId: applicationId,
        candidateId: candidateId,
        jobId: jobId,
        status: AppConstants.applicationStatusPending,
        appliedAt: DateTime.now(),
        requiredDocumentIds: requiredDocumentIds,
        uploadedDocumentIds: [],
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
          applicationId: data['applicationId'] ?? '',
          candidateId: data['candidateId'] ?? '',
          jobId: data['jobId'] ?? '',
          status: data['status'] ?? AppConstants.applicationStatusPending,
          appliedAt:
              (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          requiredDocumentIds: List<String>.from(data['requiredDocumentIds'] ?? []),
          uploadedDocumentIds: List<String>.from(data['uploadedDocumentIds'] ?? []),
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
    return firestoreDataSource
        .streamApplications(
          candidateId: candidateId,
          jobId: jobId,
          status: status,
        )
        .map((appsData) {
          return appsData.map((data) {
            return ApplicationModel(
              applicationId: data['applicationId'] ?? '',
              candidateId: data['candidateId'] ?? '',
              jobId: data['jobId'] ?? '',
              status: data['status'] ?? AppConstants.applicationStatusPending,
              appliedAt:
                  (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              requiredDocumentIds: List<String>.from(data['requiredDocumentIds'] ?? []),
              uploadedDocumentIds: List<String>.from(data['uploadedDocumentIds'] ?? []),
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
        requiredDocumentIds: [],
        uploadedDocumentIds: [],
      );

      return Right(app.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteApplication({
    required String applicationId,
  }) async {
    try {
      await firestoreDataSource.deleteApplication(applicationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationsForDocument({
    required String candidateId,
    required String docTypeId,
    required bool isUploaded,
  }) async {
    try {
      // Get all applications for this candidate
      final appsData = await firestoreDataSource.getApplications(
        candidateId: candidateId,
      );

      // Update each application that requires this document
      for (final appData in appsData) {
        final requiredDocIds = List<String>.from(appData['requiredDocumentIds'] ?? []);
        
        // Only update if this document is required by the application
        if (requiredDocIds.contains(docTypeId)) {
          final uploadedDocIds = List<String>.from(appData['uploadedDocumentIds'] ?? []);
          final applicationId = appData['applicationId'] as String;
          
          if (isUploaded) {
            // Add docTypeId if not already present
            if (!uploadedDocIds.contains(docTypeId)) {
              uploadedDocIds.add(docTypeId);
              await firestoreDataSource.updateApplication(
                applicationId: applicationId,
                data: {'uploadedDocumentIds': uploadedDocIds},
              );
            }
          } else {
            // Remove docTypeId if present
            if (uploadedDocIds.contains(docTypeId)) {
              uploadedDocIds.remove(docTypeId);
              await firestoreDataSource.updateApplication(
                applicationId: applicationId,
                data: {'uploadedDocumentIds': uploadedDocIds},
              );
            }
          }
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
