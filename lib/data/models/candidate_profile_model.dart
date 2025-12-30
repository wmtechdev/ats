import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateProfileModel extends CandidateProfileEntity {
  CandidateProfileModel({
    required super.profileId,
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.address,
    super.workHistory,
    super.assignedAgentId,
  });

  factory CandidateProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateProfileModel(
      profileId: doc.id,
      userId: data['userId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      workHistory: data['workHistory'] != null
          ? List<Map<String, dynamic>>.from(data['workHistory'])
          : null,
      assignedAgentId: data['assignedAgentId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
      if (workHistory != null) 'workHistory': workHistory,
      if (assignedAgentId != null) 'assignedAgentId': assignedAgentId,
    };
  }

  CandidateProfileEntity toEntity() {
    return CandidateProfileEntity(
      profileId: profileId,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      workHistory: workHistory,
      assignedAgentId: assignedAgentId,
    );
  }
}

