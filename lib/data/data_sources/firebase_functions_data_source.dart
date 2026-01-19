import 'package:cloud_functions/cloud_functions.dart';
import 'package:ats/core/errors/exceptions.dart';

/// Data source for calling Firebase Cloud Functions
abstract class FirebaseFunctionsDataSource {
  /// Creates an admin user without automatically signing them in
  /// Returns the created admin profile data
  Future<Map<String, dynamic>> createAdmin({
    required String email,
    required String password,
    required String name,
    required String accessLevel,
  });

  /// Creates a candidate user without automatically signing them in
  /// Returns the created candidate profile data
  Future<Map<String, dynamic>> createCandidate({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? address,
  });

  /// Deletes a candidate user and all associated data (documents, applications, profile, user)
  Future<void> deleteCandidate({
    required String userId,
    required String profileId,
  });

  /// Deletes a user from both Firebase Authentication and Firestore
  Future<void> deleteUser({required String userId, required String profileId});

  /// Sends a document denial email to a candidate
  Future<void> sendDocumentDenialEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
  });

  /// Sends a document request email to a candidate
  Future<void> sendDocumentRequestEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    required String documentDescription,
  });

  /// Sends a document request revocation email to a candidate
  Future<void> sendDocumentRequestRevocationEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  });

  /// Sends an email notification to a candidate when admin uploads a document on their behalf
  Future<void> sendAdminDocumentUploadEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  });
}

class FirebaseFunctionsDataSourceImpl implements FirebaseFunctionsDataSource {
  final FirebaseFunctions firebaseFunctions;

  FirebaseFunctionsDataSourceImpl(this.firebaseFunctions);

  @override
  Future<Map<String, dynamic>> createAdmin({
    required String email,
    required String password,
    required String name,
    required String accessLevel,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable('createAdmin');
      final result = await callable.call({
        'email': email,
        'password': password,
        'name': name,
        'accessLevel': accessLevel,
      });

      final data = result.data as Map<String, dynamic>;
      return data;
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to create admin: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createCandidate({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? address,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable('createCandidate');
      final result = await callable.call({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'address': address,
      });

      final data = result.data as Map<String, dynamic>;
      return data;
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to create candidate: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteCandidate({
    required String userId,
    required String profileId,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable('deleteCandidate');
      await callable.call({'userId': userId, 'profileId': profileId});
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to delete candidate: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteUser({
    required String userId,
    required String profileId,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable('deleteUser');
      await callable.call({'userId': userId, 'profileId': profileId});
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to delete user: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> sendDocumentDenialEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable(
        'sendDocumentDenialEmail',
      );
      await callable.call({
        'candidateEmail': candidateEmail,
        'candidateName': candidateName,
        'documentName': documentName,
        'denialReason': denialReason,
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to send email: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> sendDocumentRequestEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    required String documentDescription,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable(
        'sendDocumentRequestEmail',
      );
      await callable.call({
        'candidateEmail': candidateEmail,
        'candidateName': candidateName,
        'documentName': documentName,
        'documentDescription': documentDescription,
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to send email: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> sendDocumentRequestRevocationEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable(
        'sendDocumentRequestRevocationEmail',
      );
      await callable.call({
        'candidateEmail': candidateEmail,
        'candidateName': candidateName,
        'documentName': documentName,
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to send email: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> sendAdminDocumentUploadEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable(
        'sendAdminDocumentUploadEmail',
      );
      await callable.call({
        'candidateEmail': candidateEmail,
        'candidateName': candidateName,
        'documentName': documentName,
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException('Failed to send email: ${e.message}');
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }
}
