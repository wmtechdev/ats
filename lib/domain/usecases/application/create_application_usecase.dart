import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:dartz/dartz.dart';

class CreateApplicationUseCase {
  final ApplicationRepository applicationRepository;
  final JobRepository jobRepository;

  CreateApplicationUseCase(
    this.applicationRepository,
    this.jobRepository,
  );

  Future<Either<Failure, ApplicationEntity>> call({
    required String candidateId,
    required String jobId,
  }) async {
    // Fetch job to get requiredDocumentIds
    final jobResult = await jobRepository.getJob(jobId);
    
    return jobResult.fold(
      (failure) => Left(failure),
      (job) {
        // Create application with requiredDocumentIds from job
        return applicationRepository.createApplication(
          candidateId: candidateId,
          jobId: jobId,
          requiredDocumentIds: job.requiredDocumentIds,
        );
      },
    );
  }
}
