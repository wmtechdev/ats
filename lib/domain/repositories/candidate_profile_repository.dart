import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class CandidateProfileRepository {
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
  });

  Future<Either<Failure, CandidateProfileEntity>> updateProfile({
    required String profileId,
    String? firstName,
    String? lastName,
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
  });

  Future<Either<Failure, CandidateProfileEntity>> getProfile(String userId);

  Stream<CandidateProfileEntity?> streamProfile(String userId);
}
