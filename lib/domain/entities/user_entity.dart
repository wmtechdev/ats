class UserEntity {
  final String userId;
  final String email;
  final String role;
  final String? profileId;
  final DateTime createdAt;

  UserEntity({
    required this.userId,
    required this.email,
    required this.role,
    this.profileId,
    required this.createdAt,
  });
}

