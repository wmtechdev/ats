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

  /// Deletes a user from both Firebase Authentication and Firestore
  Future<void> deleteUser({
    required String userId,
    required String profileId,
  });

  /// Sends a document denial email to a candidate
  Future<void> sendDocumentDenialEmail({
    required String candidateEmail,
    required String candidateName,
    required String documentName,
    String? denialReason,
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
  Future<void> deleteUser({
    required String userId,
    required String profileId,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable('deleteUser');
      await callable.call({
        'userId': userId,
        'profileId': profileId,
      });
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
      final callable = firebaseFunctions.httpsCallable('sendDocumentDenialEmail');
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
}

