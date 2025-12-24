class CandidateDocumentEntity {
  final String candidateDocId;
  final String candidateId;
  final String docTypeId;
  final String documentName;
  final String storageUrl;
  final String status;
  final DateTime uploadedAt;
  final String? title;
  final String? description;

  CandidateDocumentEntity({
    required this.candidateDocId,
    required this.candidateId,
    required this.docTypeId,
    required this.documentName,
    required this.storageUrl,
    required this.status,
    required this.uploadedAt,
    this.title,
    this.description,
  });

  bool get isUserAdded => docTypeId.isEmpty;
}

