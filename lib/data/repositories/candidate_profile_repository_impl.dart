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
            return Map<String, dynamic>.from(item.map((key, value) => MapEntry(key.toString(), value)));
          }
          return <String, dynamic>{};
        })
        .where((map) => map.isNotEmpty)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  }) async {
    try {
      final profileId = await firestoreDataSource.createCandidateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        workHistory: workHistory,
      );

      final profileData = await firestoreDataSource.getCandidateProfile(profileId);
      if (profileData == null) {
        return const Left(ServerFailure('Failed to retrieve profile'));
      }

      final profileModel = CandidateProfileModel(
        profileId: profileId,
        userId: profileData['userId'] ?? userId,
        firstName: profileData['firstName'] ?? firstName,
        lastName: profileData['lastName'] ?? lastName,
        phone: profileData['phone'] ?? phone,
        address: profileData['address'] ?? address,
        workHistory: _parseWorkHistory(profileData['workHistory']),
        assignedAgentId: profileData['assignedAgentId'] as String?,
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
        updateData['assignedAgentId'] = assignedAgentId.isEmpty ? null : assignedAgentId;
      }

      await firestoreDataSource.updateCandidateProfile(
        profileId: profileId,
        data: updateData,
      );

      final profileData = await firestoreDataSource.getCandidateProfile(profileId);
      if (profileData == null) {
        return const Left(ServerFailure('Failed to retrieve updated profile'));
      }

      final profileModel = CandidateProfileModel(
        profileId: profileId,
        userId: profileData['userId'] ?? '',
        firstName: profileData['firstName'] ?? '',
        lastName: profileData['lastName'] ?? '',
        phone: profileData['phone'] ?? '',
        address: profileData['address'] ?? '',
        workHistory: _parseWorkHistory(profileData['workHistory']),
        assignedAgentId: profileData['assignedAgentId'] as String?,
      );

      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> getProfile(String userId) async {
    try {
      final profileData = await firestoreDataSource.getCandidateProfileByUserId(userId);
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
      final profileModel = CandidateProfileModel(
        profileId: '', // Will be populated from stream or when updating
        userId: profileData['userId'] ?? userId,
        firstName: profileData['firstName'] ?? '',
        lastName: profileData['lastName'] ?? '',
        phone: profileData['phone'] ?? '',
        address: profileData['address'] ?? '',
        workHistory: _parseWorkHistory(profileData['workHistory']),
        assignedAgentId: profileData['assignedAgentId'] as String?,
      );

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
      return CandidateProfileModel(
        profileId: data['profileId'] ?? '',
        userId: data['userId'] ?? userId,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        phone: data['phone'] ?? '',
        address: data['address'] ?? '',
        workHistory: _parseWorkHistory(data['workHistory']),
        assignedAgentId: data['assignedAgentId'] as String?,
      ).toEntity();
    });
  }
}

