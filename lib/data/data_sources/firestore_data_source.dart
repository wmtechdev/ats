import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';

abstract class FirestoreDataSource {
  // Users
  Future<void> createUser({
    required String userId,
    required String email,
    required String role,
    String? profileId,
  });

  Future<Map<String, dynamic>?> getUser(String userId);

  Stream<Map<String, dynamic>?> streamUser(String userId);

  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  });

  // Candidate Profiles
  Future<String> createCandidateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  });

  Future<Map<String, dynamic>?> getCandidateProfile(String profileId);

  Future<Map<String, dynamic>?> getCandidateProfileByUserId(String userId);

  Future<void> updateCandidateProfile({
    required String profileId,
    required Map<String, dynamic> data,
  });

  Stream<Map<String, dynamic>?> streamCandidateProfile(String userId);

  // Admin Profiles
  Future<String> createAdminProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String accessLevel,
  });

  Future<Map<String, dynamic>?> getAdminProfile(String profileId);

  Future<Map<String, dynamic>?> getAdminProfileByUserId(String userId);

  Future<void> updateAdminProfile({
    required String profileId,
    required Map<String, dynamic> data,
  });

  // Jobs
  Future<String> createJob({
    required String title,
    required String description,
    required String requirements,
    required List<String> requiredDocumentIds,
  });

  Future<Map<String, dynamic>?> getJob(String jobId);

  Future<List<Map<String, dynamic>>> getJobs({String? status});

  Stream<List<Map<String, dynamic>>> streamJobs({String? status});

  Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteJob(String jobId);

  // Applications
  Future<String> createApplication({
    required String candidateId,
    required String jobId,
  });

  Future<List<Map<String, dynamic>>> getApplications({
    String? candidateId,
    String? jobId,
    String? status,
  });

  Stream<List<Map<String, dynamic>>> streamApplications({
    String? candidateId,
    String? jobId,
    String? status,
  });

  Future<void> updateApplication({
    required String applicationId,
    required Map<String, dynamic> data,
  });

  // Document Types
  Future<String> createDocumentType({
    required String name,
    required String description,
    required bool isRequired,
  });

  Future<List<Map<String, dynamic>>> getDocumentTypes();

  Stream<List<Map<String, dynamic>>> streamDocumentTypes();

  Future<void> updateDocumentType({
    required String docTypeId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteDocumentType(String docTypeId);

  // Candidate Documents
  Future<String> createCandidateDocument({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required String storageUrl,
  });

  Future<List<Map<String, dynamic>>> getCandidateDocuments(String candidateId);

  Stream<List<Map<String, dynamic>>> streamCandidateDocuments(String candidateId);

  Future<void> updateCandidateDocument({
    required String candidateDocId,
    required Map<String, dynamic> data,
  });

  // Admin
  Future<List<Map<String, dynamic>>> getCandidates();
}

class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore firestore;

  FirestoreDataSourceImpl(this.firestore);

  @override
  Future<void> createUser({
    required String userId,
    required String email,
    required String role,
    String? profileId,
  }) async {
    try {
      await firestore.collection(AppConstants.usersCollection).doc(userId).set({
        'email': email,
        'role': role,
        'profileId': profileId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to create user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update user: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamUser(String userId) {
    return firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  @override
  Future<String> createCandidateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  }) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.candidateProfilesCollection)
          .add({
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'address': address,
        if (workHistory != null) 'workHistory': workHistory,
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create candidate profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCandidateProfile(String profileId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.candidateProfilesCollection)
          .doc(profileId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get candidate profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCandidateProfileByUserId(
      String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.candidateProfilesCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get candidate profile: $e');
    }
  }

  @override
  Future<void> updateCandidateProfile({
    required String profileId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.candidateProfilesCollection)
          .doc(profileId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update candidate profile: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamCandidateProfile(String userId) {
    return firestore
        .collection(AppConstants.candidateProfilesCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null);
  }

  @override
  Future<String> createAdminProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String accessLevel,
  }) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.adminProfilesCollection)
          .add({
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'accessLevel': accessLevel,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create admin profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getAdminProfile(String profileId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.adminProfilesCollection)
          .doc(profileId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get admin profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getAdminProfileByUserId(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.adminProfilesCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get admin profile: $e');
    }
  }

  @override
  Future<void> updateAdminProfile({
    required String profileId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.adminProfilesCollection)
          .doc(profileId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update admin profile: $e');
    }
  }

  @override
  Future<String> createJob({
    required String title,
    required String description,
    required String requirements,
    required List<String> requiredDocumentIds,
  }) async {
    try {
      final docRef = await firestore.collection(AppConstants.jobsCollection).add({
        'title': title,
        'description': description,
        'requirements': requirements,
        'requiredDocumentIds': requiredDocumentIds,
        'status': AppConstants.jobStatusOpen,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create job: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getJob(String jobId) async {
    try {
      final doc =
          await firestore.collection(AppConstants.jobsCollection).doc(jobId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get job: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getJobs({String? status}) async {
    try {
      Query query = firestore.collection(AppConstants.jobsCollection);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'jobId': doc.id,
              })
          .toList();
    } catch (e) {
      throw ServerException('Failed to get jobs: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamJobs({String? status}) {
    Query query = firestore.collection(AppConstants.jobsCollection);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'jobId': doc.id,
            })
        .toList());
  }

  @override
  Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.jobsCollection)
          .doc(jobId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update job: $e');
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await firestore.collection(AppConstants.jobsCollection).doc(jobId).delete();
    } catch (e) {
      throw ServerException('Failed to delete job: $e');
    }
  }

  @override
  Future<String> createApplication({
    required String candidateId,
    required String jobId,
  }) async {
    try {
      final docRef =
          await firestore.collection(AppConstants.applicationsCollection).add({
        'candidateId': candidateId,
        'jobId': jobId,
        'status': AppConstants.applicationStatusPending,
        'appliedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create application: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getApplications({
    String? candidateId,
    String? jobId,
    String? status,
  }) async {
    try {
      Query query = firestore.collection(AppConstants.applicationsCollection);
      if (candidateId != null) {
        query = query.where('candidateId', isEqualTo: candidateId);
      }
      if (jobId != null) {
        query = query.where('jobId', isEqualTo: jobId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw ServerException('Failed to get applications: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamApplications({
    String? candidateId,
    String? jobId,
    String? status,
  }) {
    Query query = firestore.collection(AppConstants.applicationsCollection);
    if (candidateId != null) {
      query = query.where('candidateId', isEqualTo: candidateId);
    }
    if (jobId != null) {
      query = query.where('jobId', isEqualTo: jobId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }

  @override
  Future<void> updateApplication({
    required String applicationId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.applicationsCollection)
          .doc(applicationId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update application: $e');
    }
  }

  @override
  Future<String> createDocumentType({
    required String name,
    required String description,
    required bool isRequired,
  }) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.documentTypesCollection)
          .add({
        'name': name,
        'description': description,
        'isRequired': isRequired,
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create document type: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDocumentTypes() async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.documentTypesCollection)
          .get();
      return querySnapshot.docs
          .map((doc) => {
                ...doc.data(),
                'docTypeId': doc.id,
              })
          .toList();
    } catch (e) {
      throw ServerException('Failed to get document types: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamDocumentTypes() {
    return firestore
        .collection(AppConstants.documentTypesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'docTypeId': doc.id,
                })
            .toList());
  }

  @override
  Future<void> updateDocumentType({
    required String docTypeId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.documentTypesCollection)
          .doc(docTypeId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update document type: $e');
    }
  }

  @override
  Future<void> deleteDocumentType(String docTypeId) async {
    try {
      await firestore
          .collection(AppConstants.documentTypesCollection)
          .doc(docTypeId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete document type: $e');
    }
  }

  @override
  Future<String> createCandidateDocument({
    required String candidateId,
    required String docTypeId,
    required String documentName,
    required String storageUrl,
  }) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.candidateDocumentsCollection)
          .add({
        'candidateId': candidateId,
        'docTypeId': docTypeId,
        'documentName': documentName,
        'storageUrl': storageUrl,
        'status': AppConstants.documentStatusPending,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create candidate document: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCandidateDocuments(
      String candidateId) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.candidateDocumentsCollection)
          .where('candidateId', isEqualTo: candidateId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw ServerException('Failed to get candidate documents: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamCandidateDocuments(
      String candidateId) {
    return firestore
        .collection(AppConstants.candidateDocumentsCollection)
        .where('candidateId', isEqualTo: candidateId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> updateCandidateDocument({
    required String candidateDocId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore
          .collection(AppConstants.candidateDocumentsCollection)
          .doc(candidateDocId)
          .update(data);
    } catch (e) {
      throw ServerException('Failed to update candidate document: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCandidates() async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.roleCandidate)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw ServerException('Failed to get candidates: $e');
    }
  }
}

