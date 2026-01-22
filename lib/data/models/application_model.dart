import 'package:ats/domain/entities/application_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel extends ApplicationEntity {
  ApplicationModel({
    required super.applicationId,
    required super.candidateId,
    required super.jobId,
    required super.status,
    required super.appliedAt,
    required super.requiredDocumentIds,
    required super.uploadedDocumentIds,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: doc.id,
      candidateId: data['candidateId'] ?? '',
      jobId: data['jobId'] ?? '',
      status: data['status'] ?? 'pending',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requiredDocumentIds: List<String>.from(data['requiredDocumentIds'] ?? []),
      uploadedDocumentIds: List<String>.from(data['uploadedDocumentIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'candidateId': candidateId,
      'jobId': jobId,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'requiredDocumentIds': requiredDocumentIds,
      'uploadedDocumentIds': uploadedDocumentIds,
    };
  }

  ApplicationEntity toEntity() {
    return ApplicationEntity(
      applicationId: applicationId,
      candidateId: candidateId,
      jobId: jobId,
      status: status,
      appliedAt: appliedAt,
      requiredDocumentIds: requiredDocumentIds,
      uploadedDocumentIds: uploadedDocumentIds,
    );
  }
}
