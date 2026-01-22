import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ApplicationRepository {
  Future<Either<Failure, ApplicationEntity>> createApplication({
    required String candidateId,
    required String jobId,
    required List<String> requiredDocumentIds,
  });

  Future<Either<Failure, List<ApplicationEntity>>> getApplications({
    String? candidateId,
    String? jobId,
    String? status,
  });

  Stream<List<ApplicationEntity>> streamApplications({
    String? candidateId,
    String? jobId,
    String? status,
  });

  Future<Either<Failure, ApplicationEntity>> updateApplicationStatus({
    required String applicationId,
    required String status,
  });

  Future<Either<Failure, void>> deleteApplication({
    required String applicationId,
  });

  /// Update uploadedDocumentIds for all applications of a candidate
  /// when a document is uploaded or deleted
  Future<Either<Failure, void>> updateApplicationsForDocument({
    required String candidateId,
    required String docTypeId,
    required bool isUploaded,
  });
}
