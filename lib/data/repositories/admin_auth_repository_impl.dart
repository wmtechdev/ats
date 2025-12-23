import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/admin_auth_repository.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

/// Admin authentication repository implementation
/// Handles admin-specific authentication with role validation
class AdminAuthRepositoryImpl implements AdminAuthRepository {
  final FirebaseAuthDataSource authDataSource;
  final FirestoreDataSource firestoreDataSource;

  AdminAuthRepositoryImpl({
    required this.authDataSource,
    required this.firestoreDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await authDataSource.signUp(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        return const Left(AuthFailure('User creation failed'));
      }

      // Create user document in Firestore with admin role
      await firestoreDataSource.createUser(
        userId: userId,
        email: email,
        role: AppConstants.roleAdmin,
      );

      // Create admin profile
      final profileId = await firestoreDataSource.createAdminProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        accessLevel: AppConstants.accessLevelRecruiter, // Default access level
      );

      // Update user with profileId
      await firestoreDataSource.updateUser(
        userId: userId,
        data: {'profileId': profileId},
      );

      // Get user data
      final userData = await firestoreDataSource.getUser(userId);
      if (userData == null) {
        return const Left(AuthFailure('Failed to retrieve user data'));
      }

      final userModel = UserModel(
        userId: userId,
        email: email,
        role: AppConstants.roleAdmin,
        profileId: profileId,
        createdAt: DateTime.now(),
      );

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await authDataSource.signIn(
        email: email,
        password: password,
      );

      final currentUser = authDataSource.getCurrentUser();
      if (currentUser == null) {
        return const Left(AuthFailure('Sign in failed'));
      }

      // Add a delay to ensure Firebase Auth token is fully propagated
      await Future.delayed(const Duration(milliseconds: 300));

      // Retry logic for reading user data
      Map<String, dynamic>? userData;
      int retries = 3;
      Exception? lastException;
      
      for (int i = 0; i < retries; i++) {
        try {
          userData = await firestoreDataSource.getUser(currentUser.uid);
          if (userData != null) break;
        } on ServerException catch (e) {
          lastException = e;
          if (i < retries - 1 && (e.message.contains('permission') || e.message.contains('Permission'))) {
            await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
            continue;
          }
          break;
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          break;
        }
        if (userData == null && i < retries - 1) {
          await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
        }
      }
      
      if (userData == null) {
        if (lastException is ServerException) {
          throw lastException;
        }
        return const Left(AuthFailure('User data not found. Please contact support.'));
      }

      // CRITICAL: Validate that user is an admin
      final userRole = userData['role'] as String?;
      if (userRole != AppConstants.roleAdmin) {
        return const Left(AuthFailure('Access denied. This account is not authorized for admin access. Please use the candidate login page.'));
      }

      final userModel = UserModel(
        userId: currentUser.uid,
        email: userData['email'] ?? currentUser.email ?? '',
        role: AppConstants.roleAdmin,
        profileId: userData['profileId'],
        createdAt: DateTime.now(),
      );

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      if (e.message.contains('permission') || e.message.contains('Permission')) {
        return const Left(AuthFailure('Permission denied. Please try again or contact support.'));
      }
      return Left(AuthFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authDataSource.signOut();
      await Future.delayed(const Duration(milliseconds: 200));
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Sign out failed: $e'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return authDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userData = await firestoreDataSource.getUser(firebaseUser.uid);
        if (userData == null) return null;

        // Only return user if they are an admin
        final userRole = userData['role'] as String?;
        if (userRole != AppConstants.roleAdmin) {
          return null; // Filter out non-admin users
        }

        return UserModel(
          userId: firebaseUser.uid,
          email: userData['email'] ?? firebaseUser.email ?? '',
          role: AppConstants.roleAdmin,
          profileId: userData['profileId'],
          createdAt: DateTime.now(),
        ).toEntity();
      } catch (e) {
        return null;
      }
    });
  }

  @override
  UserEntity? getCurrentUser() {
    final firebaseUser = authDataSource.getCurrentUser();
    if (firebaseUser == null) return null;

    // Note: This is a synchronous method, so we can't fetch from Firestore
    // In a real implementation, you might want to cache the user data
    return UserEntity(
      userId: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: AppConstants.roleAdmin, // Assume admin for this context
      createdAt: DateTime.now(),
    );
  }
}

