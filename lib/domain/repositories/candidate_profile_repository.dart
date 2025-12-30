import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class CandidateProfileRepository {
  Future<Either<Failure, CandidateProfileEntity>> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  });

  Future<Either<Failure, CandidateProfileEntity>> updateProfile({
    required String profileId,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    List<Map<String, dynamic>>? workHistory,
    String? assignedAgentId,
  });

  Future<Either<Failure, CandidateProfileEntity>> getProfile(String userId);

  Stream<CandidateProfileEntity?> streamProfile(String userId);
}

