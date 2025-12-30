class CandidateProfileEntity {
  final String profileId;
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final List<Map<String, dynamic>>? workHistory;
  final String? assignedAgentId;

  CandidateProfileEntity({
    required this.profileId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    this.workHistory,
    this.assignedAgentId,
  });
}

