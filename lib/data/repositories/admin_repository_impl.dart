import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirestoreDataSource firestoreDataSource;
  final FirebaseAuthDataSource authDataSource;

  AdminRepositoryImpl({
    required this.firestoreDataSource,
    required this.authDataSource,
  });

  @override
  Future<Either<Failure, AdminProfileEntity>> getAdminProfile(
      String userId) async {
    try {
      // This would need to be implemented in FirestoreDataSource
      // For now, returning a placeholder
      return const Left(ServerFailure('Not implemented'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getCandidates() async {
    try {
      final candidatesData = await firestoreDataSource.getCandidates();
      final candidates = candidatesData.map((data) {
        return UserModel(
          userId: '', // This needs to be fixed
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          profileId: data['profileId'],
          createdAt: DateTime.now(),
        ).toEntity();
      }).toList();
      return Right(candidates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminProfileEntity>> createAdmin({
    required String email,
    required String password,
    required String name,
    required String accessLevel,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await authDataSource.signUp(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        return const Left(AuthFailure('Admin creation failed'));
      }

      // Create user document in Firestore
      await firestoreDataSource.createUser(
        userId: userId,
        email: email,
        role: 'admin',
      );

      // Create admin profile (would need to be implemented)
      // For now, returning a placeholder
      return const Left(ServerFailure('Admin profile creation not implemented'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}

