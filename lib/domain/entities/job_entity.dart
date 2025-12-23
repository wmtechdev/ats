class JobEntity {
  final String jobId;
  final String title;
  final String description;
  final String requirements;
  final List<String> requiredDocumentIds;
  final String status;
  final DateTime createdAt;

  JobEntity({
    required this.jobId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.requiredDocumentIds,
    required this.status,
    required this.createdAt,
  });
}

