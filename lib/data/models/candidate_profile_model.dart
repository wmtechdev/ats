import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateProfileModel extends CandidateProfileEntity {
  CandidateProfileModel({
    required super.profileId,
    required super.userId,
    required super.firstName,
    required super.lastName,
    super.workHistory,
    super.assignedAgentId,
    super.middleName,
    super.email,
    super.address1,
    super.address2,
    super.city,
    super.state,
    super.zip,
    super.ssn,
    super.phones,
    super.profession,
    super.specialties,
    super.liabilityAction,
    super.licenseAction,
    super.previouslyTraveled,
    super.terminatedFromAssignment,
    super.licensureState,
    super.npi,
    super.education,
    super.certifications,
  });

  factory CandidateProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateProfileModel(
      profileId: doc.id,
      userId: data['userId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      workHistory: data['workHistory'] != null
          ? List<Map<String, dynamic>>.from(data['workHistory'])
          : null,
      assignedAgentId: data['assignedAgentId'] as String?,
      middleName: data['middleName'] as String?,
      email: data['email'] as String?,
      address1: data['address1'] as String?,
      address2: data['address2'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      zip: data['zip'] as String?,
      ssn: data['ssn'] as String?,
      phones: data['phones'] != null
          ? List<Map<String, dynamic>>.from(data['phones'])
          : null,
      profession: data['profession'] as String?,
      specialties: data['specialties'] as String?,
      liabilityAction: data['liabilityAction'] as String?,
      licenseAction: data['licenseAction'] as String?,
      previouslyTraveled: data['previouslyTraveled'] as String?,
      terminatedFromAssignment: data['terminatedFromAssignment'] as String?,
      licensureState: data['licensureState'] as String?,
      npi: data['npi'] as String?,
      education: data['education'] != null
          ? List<Map<String, dynamic>>.from(data['education'])
          : null,
      certifications: data['certifications'] != null
          ? List<Map<String, dynamic>>.from(data['certifications'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      if (workHistory != null) 'workHistory': workHistory,
      if (assignedAgentId != null) 'assignedAgentId': assignedAgentId,
      if (middleName != null) 'middleName': middleName,
      if (email != null) 'email': email,
      if (address1 != null) 'address1': address1,
      if (address2 != null) 'address2': address2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zip != null) 'zip': zip,
      if (ssn != null) 'ssn': ssn,
      if (phones != null) 'phones': phones,
      if (profession != null) 'profession': profession,
      if (specialties != null) 'specialties': specialties,
      if (liabilityAction != null) 'liabilityAction': liabilityAction,
      if (licenseAction != null) 'licenseAction': licenseAction,
      if (previouslyTraveled != null) 'previouslyTraveled': previouslyTraveled,
      if (terminatedFromAssignment != null)
        'terminatedFromAssignment': terminatedFromAssignment,
      if (licensureState != null) 'licensureState': licensureState,
      if (npi != null) 'npi': npi,
      if (education != null) 'education': education,
      if (certifications != null) 'certifications': certifications,
    };
  }

  CandidateProfileEntity toEntity() {
    return CandidateProfileEntity(
      profileId: profileId,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      workHistory: workHistory,
      assignedAgentId: assignedAgentId,
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
