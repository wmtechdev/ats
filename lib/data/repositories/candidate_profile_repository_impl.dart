import 'package:ats/core/errors/failures.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/models/candidate_profile_model.dart';
import 'package:dartz/dartz.dart';

class CandidateProfileRepositoryImpl implements CandidateProfileRepository {
  final FirestoreDataSource firestoreDataSource;

  CandidateProfileRepositoryImpl(this.firestoreDataSource);

  // Helper method to safely cast workHistory from Firestore
  List<Map<String, dynamic>>? _parseWorkHistory(dynamic workHistoryData) {
    if (workHistoryData == null) return null;
    if (workHistoryData is! List) return null;
    return workHistoryData
        .map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value)),
            );
          }
          return <String, dynamic>{};
        })
        .where((map) => map.isNotEmpty)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Helper method to parse any list of maps from Firestore
  List<Map<String, dynamic>>? _parseListOfMaps(dynamic data) {
    if (data == null) return null;
    if (data is! List) return null;
    return data
        .map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value)),
            );
          }
          return <String, dynamic>{};
        })
        .where((map) => map.isNotEmpty)
        .cast<Map<String, dynamic>>()
        .toList();
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

  @override
  Future<Either<Failure, CandidateProfileEntity>> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    List<Map<String, dynamic>>? workHistory,
    String? middleName,
    String? email,
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
  }) async {
    try {
      // Create initial profile with basic fields
      final profileId = await firestoreDataSource.createCandidateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        workHistory: workHistory,
      );

      // Update with all additional fields
      final updateData = <String, dynamic>{};
      if (middleName != null && middleName.isNotEmpty) {
        updateData['middleName'] = middleName;
      }
      if (email != null && email.isNotEmpty) updateData['email'] = email;
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
      if (phones != null) updateData['phones'] = phones;
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
      if (education != null) updateData['education'] = education;
      if (certifications != null) updateData['certifications'] = certifications;

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
        return const Left(ServerFailure('Failed to retrieve profile'));
      }

      final profileModel = _createProfileModelFromData(
        profileData,
        profileId,
        userId,
      );
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> updateProfile({
    required String profileId,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    List<Map<String, dynamic>>? workHistory,
    String? assignedAgentId,
    String? middleName,
    String? email,
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
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (workHistory != null) updateData['workHistory'] = workHistory;
      // Handle assignedAgentId: if provided (not null), include it in update
      // Empty string means unassign (set to null), otherwise use the value
      if (assignedAgentId != null) {
        updateData['assignedAgentId'] = assignedAgentId.isEmpty
            ? null
            : assignedAgentId;
      }
      if (middleName != null) {
        updateData['middleName'] = middleName.isEmpty ? null : middleName;
      }
      if (email != null) updateData['email'] = email.isEmpty ? null : email;
      if (address1 != null) {
        updateData['address1'] = address1.isEmpty ? null : address1;
      }
      if (address2 != null) {
        updateData['address2'] = address2.isEmpty ? null : address2;
      }
      if (city != null) updateData['city'] = city.isEmpty ? null : city;
      if (state != null) updateData['state'] = state.isEmpty ? null : state;
      if (zip != null) updateData['zip'] = zip.isEmpty ? null : zip;
      if (ssn != null) updateData['ssn'] = ssn.isEmpty ? null : ssn;
      if (phones != null) updateData['phones'] = phones;
      if (profession != null) {
        updateData['profession'] = profession.isEmpty ? null : profession;
      }
      if (specialties != null) {
        updateData['specialties'] = specialties.isEmpty ? null : specialties;
      }
      if (liabilityAction != null) {
        updateData['liabilityAction'] = liabilityAction.isEmpty
            ? null
            : liabilityAction;
      }
      if (licenseAction != null) {
        updateData['licenseAction'] = licenseAction.isEmpty
            ? null
            : licenseAction;
      }
      if (previouslyTraveled != null) {
        updateData['previouslyTraveled'] = previouslyTraveled.isEmpty
            ? null
            : previouslyTraveled;
      }
      if (terminatedFromAssignment != null) {
        updateData['terminatedFromAssignment'] =
            terminatedFromAssignment.isEmpty ? null : terminatedFromAssignment;
      }
      if (licensureState != null) {
        updateData['licensureState'] = licensureState.isEmpty
            ? null
            : licensureState;
      }
      if (npi != null) updateData['npi'] = npi.isEmpty ? null : npi;
      if (education != null) updateData['education'] = education;
      if (certifications != null) updateData['certifications'] = certifications;

      await firestoreDataSource.updateCandidateProfile(
        profileId: profileId,
        data: updateData,
      );

      final profileData = await firestoreDataSource.getCandidateProfile(
        profileId,
      );
      if (profileData == null) {
        return const Left(ServerFailure('Failed to retrieve updated profile'));
      }

      final profileModel = _createProfileModelFromData(
        profileData,
        profileId,
        profileData['userId'] ?? '',
      );
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> getProfile(
    String userId,
  ) async {
    try {
      final profileData = await firestoreDataSource.getCandidateProfileByUserId(
        userId,
      );
      if (profileData == null) {
        return const Left(ServerFailure('Profile not found'));
      }

      // We need to get the profileId, but getCandidateProfileByUserId doesn't return it
      // So we'll need to query again or modify the data source
      // For now, let's try to get it from the user's profileId field
      // Actually, we can use streamProfile which now includes profileId
      // But for a one-time get, we need a different approach
      // Let's add profileId to the data source method or query directly
      // For now, we'll use an empty profileId and handle updates differently
      final profileModel = _createProfileModelFromData(profileData, '', userId);

      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<CandidateProfileEntity?> streamProfile(String userId) {
    return firestoreDataSource.streamCandidateProfile(userId).map((data) {
      if (data == null) return null;
      return _createProfileModelFromData(
        data,
        data['profileId'] ?? '',
        userId,
      ).toEntity();
    });
  }
}
