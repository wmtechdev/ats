import 'package:firebase_auth/firebase_auth.dart';
import 'package:ats/core/errors/exceptions.dart';

abstract class FirebaseAuthDataSource {
  Future<UserCredential> signUp({
    required String email,
    required String password,
  });

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> reauthenticateWithPassword(String email, String password);

  Future<void> deleteUser(String userId);

  Stream<User?> get authStateChanges;

  User? getCurrentUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user is currently signed in');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to update password');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String email, String password) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user is currently signed in');
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to reauthenticate');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      } else {
        // If the user to delete is not the current user, we need to use Admin SDK
        // For now, throw an exception as client SDK can only delete current user
        throw AuthException(
          'Cannot delete user: Only the current user can be deleted',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to delete user');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() => firebaseAuth.currentUser;
}
