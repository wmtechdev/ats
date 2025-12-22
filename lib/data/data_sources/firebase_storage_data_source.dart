import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ats/core/errors/exceptions.dart';

abstract class FirebaseStorageDataSource {
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required File file,
  });

  Future<void> deleteFile(String path);

  Future<String> getDownloadUrl(String path);
}

class FirebaseStorageDataSourceImpl implements FirebaseStorageDataSource {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageDataSourceImpl(this.firebaseStorage);

  @override
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required File file,
  }) async {
    try {
      final ref = firebaseStorage.ref().child(path).child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Failed to upload file: $e');
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      await firebaseStorage.ref().child(path).delete();
    } catch (e) {
      throw StorageException('Failed to delete file: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    try {
      return await firebaseStorage.ref().child(path).getDownloadURL();
    } catch (e) {
      throw StorageException('Failed to get download URL: $e');
    }
  }
}

