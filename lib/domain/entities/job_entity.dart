class JobEntity {
  final String jobId;
  final String title;
  final String description;
  final String hospitalName;
  final List<String> requirements;
  final String status;
  final DateTime createdAt;

  JobEntity({
    required this.jobId,
    required this.title,
    required this.description,
    required this.hospitalName,
    required this.requirements,
    required this.status,
    required this.createdAt,
  });
}

