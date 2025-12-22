import 'package:ats/domain/entities/job_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel extends JobEntity {
  JobModel({
    required super.jobId,
    required super.title,
    required super.description,
    required super.hospitalName,
    required super.requirements,
    required super.status,
    required super.createdAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      jobId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'hospitalName': hospitalName,
      'requirements': requirements,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  JobEntity toEntity() {
    return JobEntity(
      jobId: jobId,
      title: title,
      description: description,
      hospitalName: hospitalName,
      requirements: requirements,
      status: status,
      createdAt: createdAt,
    );
  }
}

