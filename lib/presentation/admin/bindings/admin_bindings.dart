import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/data/repositories/job_repository_impl.dart';
import 'package:ats/data/repositories/document_repository_impl.dart';
import 'package:ats/data/repositories/application_repository_impl.dart';
import 'package:ats/data/repositories/admin_repository_impl.dart';
// import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_dashboard_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';

class AdminBindings extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    final authDataSource = FirebaseAuthDataSourceImpl(FirebaseAuth.instance);
    final firestoreDataSource = FirestoreDataSourceImpl(FirebaseFirestore.instance);
    final storageDataSource = FirebaseStorageDataSourceImpl(FirebaseStorage.instance);

    // Get globally registered AuthRepository (commented out until Firebase access)
    // final authRepo = Get.find<AuthRepository>();

    // Repositories
    final jobRepo = JobRepositoryImpl(firestoreDataSource);
    final documentRepo = DocumentRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      storageDataSource: storageDataSource,
    );
    final applicationRepo = ApplicationRepositoryImpl(firestoreDataSource);
    final adminRepo = AdminRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      authDataSource: authDataSource,
    );

    // Register repositories
    Get.lazyPut<JobRepository>(() => jobRepo);
    Get.lazyPut<DocumentRepository>(() => documentRepo);
    Get.lazyPut<ApplicationRepository>(() => applicationRepo);
    Get.lazyPut<AdminRepository>(() => adminRepo);

    // Controllers
    // Temporary: No AuthRepository needed until Firebase access
    Get.lazyPut(() => AdminAuthController());
    // Get.lazyPut(() => AdminAuthController(authRepo));
    Get.lazyPut(() => AdminDashboardController(applicationRepo, jobRepo));
    Get.lazyPut(() => AdminJobsController(jobRepo));
    Get.lazyPut(() => AdminCandidatesController(adminRepo, applicationRepo, documentRepo));
    Get.lazyPut(() => AdminDocumentsController(documentRepo));
  }
}

