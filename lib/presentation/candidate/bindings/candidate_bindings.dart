import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/data/repositories/candidate_profile_repository_impl.dart';
import 'package:ats/data/repositories/job_repository_impl.dart';
import 'package:ats/data/repositories/document_repository_impl.dart';
import 'package:ats/data/repositories/application_repository_impl.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/presentation/candidate/controllers/auth_controller.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/presentation/candidate/controllers/documents_controller.dart';
import 'package:ats/presentation/candidate/controllers/applications_controller.dart';

class CandidateBindings extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    final firestoreDataSource = FirestoreDataSourceImpl(FirebaseFirestore.instance);
    final storageDataSource = FirebaseStorageDataSourceImpl(FirebaseStorage.instance);

    // Get globally registered AuthRepository
    final authRepo = Get.find<AuthRepository>();

    // Repositories
    final profileRepo = CandidateProfileRepositoryImpl(firestoreDataSource);
    final jobRepo = JobRepositoryImpl(firestoreDataSource);
    final documentRepo = DocumentRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      storageDataSource: storageDataSource,
    );
    final applicationRepo = ApplicationRepositoryImpl(firestoreDataSource);

    // Register repositories
    Get.lazyPut<CandidateProfileRepository>(() => profileRepo);
    Get.lazyPut<JobRepository>(() => jobRepo);
    Get.lazyPut<DocumentRepository>(() => documentRepo);
    Get.lazyPut<ApplicationRepository>(() => applicationRepo);

    // Controllers
    Get.lazyPut(() => AuthController(authRepo));
    Get.lazyPut(() => ProfileController(profileRepo, authRepo));
    Get.lazyPut(() => JobsController(jobRepo, applicationRepo, authRepo));
    Get.lazyPut(() => DocumentsController(documentRepo, authRepo));
    Get.lazyPut(() => ApplicationsController(applicationRepo, authRepo));
  }
}

