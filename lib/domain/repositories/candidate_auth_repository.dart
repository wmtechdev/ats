import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

/// Candidate authentication repository interface
/// Handles candidate-specific authentication operations
abstract class CandidateAuthRepository {
  /// Sign up a new candidate user
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? address,
  });

  /// Sign in a candidate user
  /// Validates that the user is a candidate before allowing sign in
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current candidate user
  Future<Either<Failure, void>> signOut();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Get the current authenticated candidate user
  UserEntity? getCurrentUser();
}

