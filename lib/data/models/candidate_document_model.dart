import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateDocumentModel extends CandidateDocumentEntity {
  CandidateDocumentModel({
    required super.candidateDocId,
    required super.candidateId,
    required super.docTypeId,
    required super.documentName,
    required super.storageUrl,
    required super.status,
    required super.uploadedAt,
  });

  factory CandidateDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateDocumentModel(
      candidateDocId: doc.id,
      candidateId: data['candidateId'] ?? '',
      docTypeId: data['docTypeId'] ?? '',
      documentName: data['documentName'] ?? '',
      storageUrl: data['storageUrl'] ?? '',
      status: data['status'] ?? 'pending',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'candidateId': candidateId,
      'docTypeId': docTypeId,
      'documentName': documentName,
      'storageUrl': storageUrl,
      'status': status,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  CandidateDocumentEntity toEntity() {
    return CandidateDocumentEntity(
      candidateDocId: candidateDocId,
      candidateId: candidateId,
      docTypeId: docTypeId,
      documentName: documentName,
      storageUrl: storageUrl,
      status: status,
      uploadedAt: uploadedAt,
    );
  }
}

