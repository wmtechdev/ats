import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminProfileEntity>> getAdminProfile(String userId);

  Future<Either<Failure, List<UserEntity>>> getCandidates();

  Future<Either<Failure, AdminProfileEntity>> createAdmin({
    required String email,
    required String password,
    required String name,
    required String accessLevel,
  });
}

