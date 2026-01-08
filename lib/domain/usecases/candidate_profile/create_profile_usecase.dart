import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:dartz/dartz.dart';

class CreateProfileUseCase {
  final CandidateProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<Either<Failure, CandidateProfileEntity>> call({
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
  }) {
    return repository.createProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      workHistory: workHistory,
      middleName: middleName,
      email: email,
      address1: address1,
      address2: address2,
      city: city,
      state: state,
      zip: zip,
      ssn: ssn,
      phones: phones,
      profession: profession,
      specialties: specialties,
      liabilityAction: liabilityAction,
      licenseAction: licenseAction,
      previouslyTraveled: previouslyTraveled,
      terminatedFromAssignment: terminatedFromAssignment,
      licensureState: licensureState,
      npi: npi,
      education: education,
      certifications: certifications,
    );
  }
}
