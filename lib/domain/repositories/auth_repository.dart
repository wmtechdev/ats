import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Stream<UserEntity?> get authStateChanges;

  UserEntity? getCurrentUser();
}

