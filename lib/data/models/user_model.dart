import 'package:ats/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.userId,
    required super.email,
    required super.role,
    super.profileId,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      profileId: data['profileId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'profileId': profileId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      role: role,
      profileId: profileId,
      createdAt: createdAt,
    );
  }
}

