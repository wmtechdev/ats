import 'package:ats/domain/entities/document_type_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentTypeModel extends DocumentTypeEntity {
  DocumentTypeModel({
    required super.docTypeId,
    required super.name,
    required super.description,
    required super.isRequired,
  });

  factory DocumentTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentTypeModel(
      docTypeId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isRequired: data['isRequired'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'isRequired': isRequired,
    };
  }

  DocumentTypeEntity toEntity() {
    return DocumentTypeEntity(
      docTypeId: docTypeId,
      name: name,
      description: description,
      isRequired: isRequired,
    );
  }
}

