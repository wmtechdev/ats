import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Get user data to find profileId
      final userData = await firestoreDataSource.getUser(userId);
      if (userData == null) {
        return const Left(ServerFailure('User not found'));
      }

      final profileId = userData['profileId'] as String?;
      if (profileId == null) {
        return const Left(ServerFailure('Admin profile not found'));
      }

      // Get admin profile data
      final profileData = await firestoreDataSource.getAdminProfile(profileId);
      if (profileData == null) {
        return const Left(ServerFailure('Admin profile not found'));
      }

      final firstName = profileData['firstName'] ?? '';
      final lastName = profileData['lastName'] ?? '';
      final name = '$firstName $lastName'.trim();
      final finalName = name.isEmpty 
          ? (firstName.isNotEmpty ? firstName : lastName)
          : name;

      // Get user email from already fetched userData
      final email = userData['email'] ?? '';

      return Right(AdminProfileEntity(
        profileId: profileId,
        userId: userId,
        name: finalName,
        accessLevel: profileData['accessLevel'] ?? AppConstants.accessLevelRecruiter,
        email: email,
      ));
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
      
      final candidates = <UserEntity>[];
      
      for (var data in candidatesData) {
        try {
          final userId = data['userId'] as String?;
          final email = data['email'] as String?;
          
          if (userId == null || userId.isEmpty) {
            continue;
          }
          
          if (email == null || email.isEmpty) {
            continue;
          }
          
          final candidate = UserModel(
            userId: userId,
            email: email,
            role: data['role'] ?? AppConstants.roleCandidate,
            profileId: data['profileId'] as String?,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ).toEntity();
          
          candidates.add(candidate);
        } catch (e) {
          continue;
        }
      }
      
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
      // Split name into firstName and lastName
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 
          ? nameParts.sublist(1).join(' ') 
          : '';

      // Create Firebase Auth user
      final userCredential = await authDataSource.signUp(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        return const Left(AuthFailure('Admin creation failed'));
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
        accessLevel: accessLevel,
      );

      // Update user with profileId
      await firestoreDataSource.updateUser(
        userId: userId,
        data: {'profileId': profileId},
      );

      // Return the created admin profile entity
      return Right(AdminProfileEntity(
        profileId: profileId,
        userId: userId,
        name: name,
        accessLevel: accessLevel,
        email: email,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminProfileEntity>>> getAllAdminProfiles() async {
    try {
      final profilesData = await firestoreDataSource.getAllAdminProfiles();
      final profiles = <AdminProfileEntity>[];

      for (var profileData in profilesData) {
        final firstName = profileData['firstName'] ?? '';
        final lastName = profileData['lastName'] ?? '';
        final name = '$firstName $lastName'.trim();
        final finalName = name.isEmpty 
            ? (firstName.isNotEmpty ? firstName : lastName)
            : name;

        // Get user email
        final userId = profileData['userId'] ?? '';
        final userData = await firestoreDataSource.getUser(userId);
        final email = userData?['email'] ?? '';

        profiles.add(AdminProfileEntity(
          profileId: profileData['profileId'] ?? '',
          userId: userId,
          name: finalName,
          accessLevel: profileData['accessLevel'] ?? AppConstants.accessLevelRecruiter,
          email: email,
        ));
      }

      return Right(profiles);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminProfileEntity>> updateAdminProfileAccessLevel({
    required String profileId,
    required String accessLevel,
  }) async {
    try {
      // Update admin profile access level
      await firestoreDataSource.updateAdminProfile(
        profileId: profileId,
        data: {'accessLevel': accessLevel},
      );

      // Get updated profile data
      final profileData = await firestoreDataSource.getAdminProfile(profileId);
      if (profileData == null) {
        return const Left(ServerFailure('Admin profile not found'));
      }

      final firstName = profileData['firstName'] ?? '';
      final lastName = profileData['lastName'] ?? '';
      final name = '$firstName $lastName'.trim();
      final finalName = name.isEmpty 
          ? (firstName.isNotEmpty ? firstName : lastName)
          : name;

      // Get user email
      final userId = profileData['userId'] ?? '';
      final userData = await firestoreDataSource.getUser(userId);
      final email = userData != null ? (userData['email'] ?? '') : '';

      return Right(AdminProfileEntity(
        profileId: profileId,
        userId: userId,
        name: finalName,
        accessLevel: accessLevel,
        email: email,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}

