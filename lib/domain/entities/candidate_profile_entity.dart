class CandidateProfileEntity {
  final String profileId;
  final String userId;
  final String firstName;
  final String lastName;
  final List<Map<String, dynamic>>? workHistory;
  final String? assignedAgentId;

  // Profile fields
  final String? middleName;
  final String? email;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? zip;
  final String? ssn;
  final List<Map<String, dynamic>>? phones;
  final String? profession;
  final String? specialties;
  final String? liabilityAction;
  final String? licenseAction;
  final String? previouslyTraveled;
  final String? terminatedFromAssignment;
  final String? licensureState;
  final String? npi;
  final List<Map<String, dynamic>>? education;
  final List<Map<String, dynamic>>? certifications;

  CandidateProfileEntity({
    required this.profileId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.workHistory,
    this.assignedAgentId,
    this.middleName,
    this.email,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip,
    this.ssn,
    this.phones,
    this.profession,
    this.specialties,
    this.liabilityAction,
    this.licenseAction,
    this.previouslyTraveled,
    this.terminatedFromAssignment,
    this.licensureState,
    this.npi,
    this.education,
    this.certifications,
  });
}
