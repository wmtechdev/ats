import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/data_sources/firebase_functions_data_source.dart';
import 'package:ats/data/models/user_model.dart';
import 'package:ats/data/models/candidate_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirestoreDataSource firestoreDataSource;
  final FirebaseAuthDataSource authDataSource;
  final FirebaseFunctionsDataSource? functionsDataSource;

  AdminRepositoryImpl({
    required this.firestoreDataSource,
    required this.authDataSource,
    this.functionsDataSource, // Optional: if provided, use Functions; otherwise use direct Firebase
  });

  @override
  Future<Either<Failure, AdminProfileEntity>> getAdminProfile(
    String userId,
  ) async {
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

      return Right(
        AdminProfileEntity(
          profileId: profileId,
          userId: userId,
          name: finalName,
          accessLevel:
              profileData['accessLevel'] ?? AppConstants.accessLevelRecruiter,
          email: email,
        ),
      );
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
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      // Use Firebase Functions if available (Firebase Admin SDK), otherwise fall back to direct Firebase
      if (functionsDataSource != null) {
        // Use Firebase Functions - creates user without auto-login
        final result = await functionsDataSource!.createAdmin(
          email: email,
          password: password,
          name: name,
          accessLevel: accessLevel,
        );

        return Right(
          AdminProfileEntity(
            profileId: result['profileId'] as String,
            userId: result['userId'] as String,
            name: result['name'] as String,
            accessLevel: result['accessLevel'] as String,
            email: result['email'] as String,
          ),
        );
      } else {
        // Fallback to direct Firebase (legacy approach)
        // Split name into firstName and lastName
        final nameParts = name.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        // Create Firebase Auth user (this will automatically sign in the new user)
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

        // Note: createUserWithEmailAndPassword automatically signs in the new user
        // Sign out the newly created user to prevent auto-login
        await authDataSource.signOut();

        // Return the created admin profile entity
        return Right(
          AdminProfileEntity(
            profileId: profileId,
            userId: userId,
            name: name,
            accessLevel: accessLevel,
            email: email,
          ),
        );
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> createCandidate({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zip,
    String? ssn,
    List<Map<String, dynamic>>? phones,
    String? profession,
    String? specialties,
    String? liabilityAction,
    String? licenseAction,
    String? previouslyTraveled,
    String? terminatedFromAssignment,
    String? licensureState,
    String? npi,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? certifications,
    List<Map<String, dynamic>>? workHistory,
  }) async {
    try {
      // Use Firebase Functions if available (Firebase Admin SDK), otherwise fall back to direct Firebase
      if (functionsDataSource != null) {
        // Use Firebase Functions - creates user without auto-login
        // Note: Functions may not support all new fields, so we'll update after creation
        final result = await functionsDataSource!.createCandidate(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: null, // Functions may not support new fields
          address: null,
        );

        // Get the created profile to return full entity
        final profileId = result['profileId'] as String;
        final userId = result['userId'] as String;

        // Update profile with all additional fields
        final updateData = <String, dynamic>{};
        if (middleName != null && middleName.isNotEmpty) {
          updateData['middleName'] = middleName;
        }
        if (address1 != null && address1.isNotEmpty) {
          updateData['address1'] = address1;
        }
        if (address2 != null && address2.isNotEmpty) {
          updateData['address2'] = address2;
        }
        if (city != null && city.isNotEmpty) updateData['city'] = city;
        if (state != null && state.isNotEmpty) updateData['state'] = state;
        if (zip != null && zip.isNotEmpty) updateData['zip'] = zip;
        if (ssn != null && ssn.isNotEmpty) updateData['ssn'] = ssn;
        if (phones != null && phones.isNotEmpty) updateData['phones'] = phones;
        if (profession != null && profession.isNotEmpty) {
          updateData['profession'] = profession;
        }
        if (specialties != null && specialties.isNotEmpty) {
          updateData['specialties'] = specialties;
        }
        if (liabilityAction != null && liabilityAction.isNotEmpty) {
          updateData['liabilityAction'] = liabilityAction;
        }
        if (licenseAction != null && licenseAction.isNotEmpty) {
          updateData['licenseAction'] = licenseAction;
        }
        if (previouslyTraveled != null && previouslyTraveled.isNotEmpty) {
          updateData['previouslyTraveled'] = previouslyTraveled;
        }
        if (terminatedFromAssignment != null &&
            terminatedFromAssignment.isNotEmpty) {
          updateData['terminatedFromAssignment'] = terminatedFromAssignment;
        }
        if (licensureState != null && licensureState.isNotEmpty) {
          updateData['licensureState'] = licensureState;
        }
        if (npi != null && npi.isNotEmpty) updateData['npi'] = npi;
        if (education != null && education.isNotEmpty) {
          updateData['education'] = education;
        }
        if (certifications != null && certifications.isNotEmpty) {
          updateData['certifications'] = certifications;
        }
        if (workHistory != null && workHistory.isNotEmpty) {
          updateData['workHistory'] = workHistory;
        }
        if (email.isNotEmpty) updateData['email'] = email;

        if (updateData.isNotEmpty) {
          await firestoreDataSource.updateCandidateProfile(
            profileId: profileId,
            data: updateData,
          );
        }

        final profileData = await firestoreDataSource.getCandidateProfile(
          profileId,
        );
        if (profileData == null) {
          return const Left(
            ServerFailure('Failed to retrieve created profile'),
          );
        }

        final profileModel = _createProfileModelFromData(
          profileData,
          profileId,
          userId,
        );
        return Right(profileModel.toEntity());
      } else {
        // Fallback to direct Firebase (legacy approach)
        // Create Firebase Auth user (this will automatically sign in the new user)
        final userCredential = await authDataSource.signUp(
          email: email,
          password: password,
        );

        final userId = userCredential.user?.uid;
        if (userId == null) {
          return const Left(AuthFailure('Candidate creation failed'));
        }

        // Create user document in Firestore with candidate role
        await firestoreDataSource.createUser(
          userId: userId,
          email: email,
          role: AppConstants.roleCandidate,
        );

        // Create candidate profile with basic fields
        final profileId = await firestoreDataSource.createCandidateProfile(
          userId: userId,
          firstName: firstName,
          lastName: lastName,
        );

        // Update user with profileId
        await firestoreDataSource.updateUser(
          userId: userId,
          data: {'profileId': profileId},
        );

        // Update profile with all additional fields
        final updateData = <String, dynamic>{};
        if (middleName != null && middleName.isNotEmpty) {
          updateData['middleName'] = middleName;
        }
        if (address1 != null && address1.isNotEmpty) {
          updateData['address1'] = address1;
        }
        if (address2 != null && address2.isNotEmpty) {
          updateData['address2'] = address2;
        }
        if (city != null && city.isNotEmpty) updateData['city'] = city;
        if (state != null && state.isNotEmpty) updateData['state'] = state;
        if (zip != null && zip.isNotEmpty) updateData['zip'] = zip;
        if (ssn != null && ssn.isNotEmpty) updateData['ssn'] = ssn;
        if (phones != null && phones.isNotEmpty) updateData['phones'] = phones;
        if (profession != null && profession.isNotEmpty) {
          updateData['profession'] = profession;
        }
        if (specialties != null && specialties.isNotEmpty) {
          updateData['specialties'] = specialties;
        }
        if (liabilityAction != null && liabilityAction.isNotEmpty) {
          updateData['liabilityAction'] = liabilityAction;
        }
        if (licenseAction != null && licenseAction.isNotEmpty) {
          updateData['licenseAction'] = licenseAction;
        }
        if (previouslyTraveled != null && previouslyTraveled.isNotEmpty) {
          updateData['previouslyTraveled'] = previouslyTraveled;
        }
        if (terminatedFromAssignment != null &&
            terminatedFromAssignment.isNotEmpty) {
          updateData['terminatedFromAssignment'] = terminatedFromAssignment;
        }
        if (licensureState != null && licensureState.isNotEmpty) {
          updateData['licensureState'] = licensureState;
        }
        if (npi != null && npi.isNotEmpty) updateData['npi'] = npi;
        if (education != null && education.isNotEmpty) {
          updateData['education'] = education;
        }
        if (certifications != null && certifications.isNotEmpty) {
          updateData['certifications'] = certifications;
        }
        if (workHistory != null && workHistory.isNotEmpty) {
          updateData['workHistory'] = workHistory;
        }
        if (email.isNotEmpty) updateData['email'] = email;

        if (updateData.isNotEmpty) {
          await firestoreDataSource.updateCandidateProfile(
            profileId: profileId,
            data: updateData,
          );
        }

        // Note: createUserWithEmailAndPassword automatically signs in the new user
        // Sign out the newly created user to prevent auto-login
        await authDataSource.signOut();

        // Get the created profile to return full entity
        final profileData = await firestoreDataSource.getCandidateProfile(
          profileId,
        );
        if (profileData == null) {
          return const Left(
            ServerFailure('Failed to retrieve created profile'),
          );
        }

        final profileModel = _createProfileModelFromData(
          profileData,
          profileId,
          userId,
        );
        return Right(profileModel.toEntity());
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminProfileEntity>>>
  getAllAdminProfiles() async {
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

        profiles.add(
          AdminProfileEntity(
            profileId: profileData['profileId'] ?? '',
            userId: userId,
            name: finalName,
            accessLevel:
                profileData['accessLevel'] ?? AppConstants.accessLevelRecruiter,
            email: email,
          ),
        );
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

      return Right(
        AdminProfileEntity(
          profileId: profileId,
          userId: userId,
          name: finalName,
          accessLevel: accessLevel,
          email: email,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCandidate({
    required String userId,
    required String profileId,
  }) async {
    try {
      // Use Firebase Functions if available (Firebase Admin SDK), otherwise fall back to direct Firebase
      if (functionsDataSource != null) {
        // Use Firebase Functions - can delete candidate and all associated data
        await functionsDataSource!.deleteCandidate(
          userId: userId,
          profileId: profileId,
        );
        return const Right(null);
      } else {
        // Fallback to direct Firebase (legacy approach)
        // Note: This won't delete Storage files or handle all cleanup properly
        // For full cleanup, Firebase Functions with Admin SDK is required

        // Note: Full candidate deletion with Storage cleanup requires Firebase Functions
        // Fallback mode will only delete Firestore data, not Storage files
        // For production, always use Firebase Functions

        // Get candidate documents to delete from Storage (if we had access)
        // For now, we'll just delete Firestore records

        // Delete candidate profile from Firestore
        // Note: We need direct Firestore access for this
        // Since we have FirestoreDataSource, we'll need to add a method or use direct access
        // For now, skip profile deletion in fallback - Functions will handle it properly

        // Delete user document from Firestore
        await firestoreDataSource.deleteUser(userId);

        // Delete user from Firebase Authentication
        // Note: Client SDK can only delete the current user
        // For deleting other users, Admin SDK is required
        try {
          await authDataSource.deleteUser(userId);
        } on AuthException catch (e) {
          // If deletion from Auth fails (e.g., trying to delete a different user),
          // we still consider it a partial success since Firestore data is deleted
          return Left(
            AuthFailure(
              'Candidate deleted from Firestore, but Auth deletion requires Admin SDK: ${e.message}',
            ),
          );
        }

        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser({
    required String userId,
    required String profileId,
  }) async {
    try {
      // Use Firebase Functions if available (Firebase Admin SDK), otherwise fall back to direct Firebase
      if (functionsDataSource != null) {
        // Use Firebase Functions - can delete any user
        await functionsDataSource!.deleteUser(
          userId: userId,
          profileId: profileId,
        );
        return const Right(null);
      } else {
        // Fallback to direct Firebase (legacy approach)
        // Delete admin profile from Firestore
        await firestoreDataSource.deleteAdminProfile(profileId);

        // Delete user document from Firestore
        await firestoreDataSource.deleteUser(userId);

        // Delete user from Firebase Authentication
        // Note: Client SDK can only delete the current user
        // For deleting other users, Admin SDK is required
        try {
          await authDataSource.deleteUser(userId);
        } on AuthException catch (e) {
          // If deletion from Auth fails (e.g., trying to delete a different user),
          // we still consider it a partial success since Firestore data is deleted
          return Left(
            AuthFailure(
              'User deleted from Firestore, but Auth deletion requires Admin SDK: ${e.message}',
            ),
          );
        }

        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  // Helper method to create profile model from Firestore data
  CandidateProfileModel _createProfileModelFromData(
    Map<String, dynamic> data,
    String profileId,
    String userId,
  ) {
    return CandidateProfileModel(
      profileId: profileId,
      userId: data['userId'] ?? userId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      workHistory: _parseWorkHistory(data['workHistory']),
      assignedAgentId: data['assignedAgentId'] as String?,
      middleName: data['middleName'] as String?,
      email: data['email'] as String?,
      address1: data['address1'] as String?,
      address2: data['address2'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      zip: data['zip'] as String?,
      ssn: data['ssn'] as String?,
      phones: _parseListOfMaps(data['phones']),
      profession: data['profession'] as String?,
      specialties: data['specialties'] as String?,
      liabilityAction: data['liabilityAction'] as String?,
      licenseAction: data['licenseAction'] as String?,
      previouslyTraveled: data['previouslyTraveled'] as String?,
      terminatedFromAssignment: data['terminatedFromAssignment'] as String?,
      licensureState: data['licensureState'] as String?,
      npi: data['npi'] as String?,
      education: _parseListOfMaps(data['education']),
      certifications: _parseListOfMaps(data['certifications']),
    );
  }

  // Helper method to parse work history
  List<Map<String, dynamic>>? _parseWorkHistory(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return Map<String, dynamic>.from(item);
      }).toList();
    }
    return null;
  }

  // Helper method to parse list of maps
  List<Map<String, dynamic>>? _parseListOfMaps(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return Map<String, dynamic>.from(item);
      }).toList();
    }
    return null;
  }
}
