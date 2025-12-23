import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

/// Admin authentication repository interface
/// Handles admin-specific authentication operations
abstract class AdminAuthRepository {
  /// Sign up a new admin user
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Sign in an admin user
  /// Validates that the user is an admin before allowing sign in
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current admin user
  Future<Either<Failure, void>> signOut();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Get the current authenticated admin user
  UserEntity? getCurrentUser();
}

