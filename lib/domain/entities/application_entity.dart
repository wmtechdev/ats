class ApplicationEntity {
  final String applicationId;
  final String candidateId;
  final String jobId;
  final String status;
  final DateTime appliedAt;
  final List<String> requiredDocumentIds;
  final List<String> uploadedDocumentIds;

  ApplicationEntity({
    required this.applicationId,
    required this.candidateId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.requiredDocumentIds,
    required this.uploadedDocumentIds,
  });
}
