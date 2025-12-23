import 'package:ats/domain/entities/job_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel extends JobEntity {
  JobModel({
    required super.jobId,
    required super.title,
    required super.description,
    required super.requirements,
    required super.requiredDocumentIds,
    required super.status,
    required super.createdAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      jobId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: data['requirements'] ?? '',
      requiredDocumentIds: List<String>.from(data['requiredDocumentIds'] ?? []),
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'requiredDocumentIds': requiredDocumentIds,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  JobEntity toEntity() {
    return JobEntity(
      jobId: jobId,
      title: title,
      description: description,
      requirements: requirements,
      requiredDocumentIds: requiredDocumentIds,
      status: status,
      createdAt: createdAt,
    );
  }
}

