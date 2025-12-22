class ApplicationEntity {
  final String applicationId;
  final String candidateId;
  final String jobId;
  final String status;
  final DateTime appliedAt;

  ApplicationEntity({
    required this.applicationId,
    required this.candidateId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
  });
}

