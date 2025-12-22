import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/auth_repository.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource authDataSource;
  final FirestoreDataSource firestoreDataSource;

  AuthRepositoryImpl({
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

      // Create user document in Firestore
      await firestoreDataSource.createUser(
        userId: userId,
        email: email,
        role: AppConstants.roleCandidate,
      );

      // Create candidate profile
      final profileId = await firestoreDataSource.createCandidateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: '',
        address: '',
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
        role: AppConstants.roleCandidate,
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

      final userData = await firestoreDataSource.getUser(currentUser.uid);
      if (userData == null) {
        return const Left(AuthFailure('User data not found'));
      }

      final userModel = UserModel(
        userId: currentUser.uid,
        email: userData['email'] ?? currentUser.email ?? '',
        role: userData['role'] ?? AppConstants.roleCandidate,
        profileId: userData['profileId'],
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
  Future<Either<Failure, void>> signOut() async {
    try {
      await authDataSource.signOut();
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

      final userData = await firestoreDataSource.getUser(firebaseUser.uid);
      if (userData == null) return null;

      return UserModel(
        userId: firebaseUser.uid,
        email: userData['email'] ?? firebaseUser.email ?? '',
        role: userData['role'] ?? AppConstants.roleCandidate,
        profileId: userData['profileId'],
        createdAt: DateTime.now(),
      ).toEntity();
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
      role: '', // Will be loaded from Firestore when needed
      createdAt: DateTime.now(),
    );
  }
}

