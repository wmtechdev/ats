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
    required String phone,
    required String address,
    List<Map<String, dynamic>>? workHistory,
  }) {
    return repository.createProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      workHistory: workHistory,
    );
  }
}

