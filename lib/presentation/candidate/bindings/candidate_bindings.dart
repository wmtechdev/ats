import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/data/data_sources/firebase_functions_data_source.dart';
import 'package:ats/data/repositories/candidate_auth_repository_impl.dart';
import 'package:ats/data/repositories/candidate_profile_repository_impl.dart';
import 'package:ats/data/repositories/job_repository_impl.dart';
import 'package:ats/data/repositories/document_repository_impl.dart';
import 'package:ats/data/repositories/application_repository_impl.dart';
import 'package:ats/data/repositories/email_repository_impl.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/presentation/candidate/controllers/candidate_auth_controller.dart';
import 'package:ats/presentation/candidate/controllers/candidate_dashboard_controller.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/presentation/candidate/controllers/applications_controller.dart';

class CandidateBindings extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    final authDataSource = FirebaseAuthDataSourceImpl(FirebaseAuth.instance);
    final firestoreDataSource = FirestoreDataSourceImpl(
      FirebaseFirestore.instance,
    );
    final storageDataSource = FirebaseStorageDataSourceImpl(
      FirebaseStorage.instance,
    );
    final functionsDataSource = FirebaseFunctionsDataSourceImpl(
      FirebaseFunctions.instance,
    );

    // Candidate Auth Repository (completely isolated)
    final candidateAuthRepo = CandidateAuthRepositoryImpl(
      authDataSource: authDataSource,
      firestoreDataSource: firestoreDataSource,
    );

    // Repositories
    final profileRepo = CandidateProfileRepositoryImpl(firestoreDataSource);
    final jobRepo = JobRepositoryImpl(firestoreDataSource);
    final documentRepo = DocumentRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      storageDataSource: storageDataSource,
    );
    final applicationRepo = ApplicationRepositoryImpl(firestoreDataSource);
    final emailRepo = EmailRepositoryImpl(
      functionsDataSource: functionsDataSource,
    );

    // Register repositories
    Get.lazyPut<CandidateAuthRepository>(() => candidateAuthRepo);
    Get.lazyPut<CandidateProfileRepository>(() => profileRepo);
    Get.lazyPut<JobRepository>(() => jobRepo);
    Get.lazyPut<DocumentRepository>(() => documentRepo);
    Get.lazyPut<ApplicationRepository>(() => applicationRepo);
    Get.lazyPut<EmailRepository>(() => emailRepo);

    // Controllers
    // Use lazyPut like AdminBindings to avoid recreating controller when navigating between routes
    Get.lazyPut<CandidateAuthController>(
      () => CandidateAuthController(candidateAuthRepo),
    );
    Get.lazyPut(
      () => CandidateDashboardController(
        candidateAuthRepo,
        applicationRepo,
        jobRepo,
        documentRepo,
      ),
    );
    Get.lazyPut(() => ProfileController(profileRepo, candidateAuthRepo));
    Get.lazyPut(
      () => JobsController(
        jobRepo,
        applicationRepo,
        candidateAuthRepo,
        profileRepo,
        documentRepo,
        emailRepo,
      ),
    );
    Get.lazyPut(() => DocumentsController(documentRepo, candidateAuthRepo, applicationRepo));
    Get.lazyPut(
      () => ApplicationsController(applicationRepo, candidateAuthRepo),
    );
  }
}
