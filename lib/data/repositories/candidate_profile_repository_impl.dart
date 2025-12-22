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
        workHistory: profileData['workHistory'],
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
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (workHistory != null) updateData['workHistory'] = workHistory;

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
        workHistory: profileData['workHistory'],
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

      // We need profileId, but we only have userId. We'll need to query differently
      // For now, let's assume we can get it from the data
      final profileModel = CandidateProfileModel(
        profileId: '', // This needs to be fixed in the data source
        userId: profileData['userId'] ?? userId,
        firstName: profileData['firstName'] ?? '',
        lastName: profileData['lastName'] ?? '',
        phone: profileData['phone'] ?? '',
        address: profileData['address'] ?? '',
        workHistory: profileData['workHistory'],
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
        profileId: '', // This needs to be fixed
        userId: data['userId'] ?? userId,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        phone: data['phone'] ?? '',
        address: data['address'] ?? '',
        workHistory: data['workHistory'],
      ).toEntity();
    });
  }
}

