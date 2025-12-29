import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ats/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Callback for upload progress tracking
typedef UploadProgressCallback = void Function(double progress);

abstract class FirebaseStorageDataSource {
  /// Uploads a file to Firebase Storage
  /// Supports both File (mobile) and Uint8List (web)
  /// 
  /// [path] - Storage path (e.g., 'documents/userId')
  /// [fileName] - Name of the file to store
  /// [file] - File object for mobile platforms
  /// [bytes] - File bytes for web platform
  /// [mimeType] - MIME type of the file (optional)
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  Future<String> uploadFile({
    required String path,
    required String fileName,
    File? file,
    Uint8List? bytes,
    String? mimeType,
    UploadProgressCallback? onProgress,
  });

  /// Deletes a file from Firebase Storage
  /// [path] - Full storage path (e.g., 'documents/userId/fileName') or storage URL
  Future<void> deleteFile(String path);
  
  /// Deletes a file from Firebase Storage using its download URL
  Future<void> deleteFileByUrl(String downloadUrl);

  /// Gets download URL for a file
  Future<String> getDownloadUrl(String path);
}

class FirebaseStorageDataSourceImpl implements FirebaseStorageDataSource {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageDataSourceImpl(this.firebaseStorage);

  @override
  Future<String> uploadFile({
    required String path,
    required String fileName,
    File? file,
    Uint8List? bytes,
    String? mimeType,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final ref = firebaseStorage.ref().child(path).child(fileName);

      UploadTask uploadTask;

      if (kIsWeb) {
        // Web platform: use bytes
        if (bytes == null) {
          throw StorageException('File bytes are required for web platform');
        }

        final metadata = mimeType != null
            ? SettableMetadata(contentType: mimeType)
            : null;

        uploadTask = ref.putData(bytes, metadata);
      } else {
        // Mobile platform: use File
        if (file == null) {
          throw StorageException('File object is required for mobile platform');
        }

        final metadata = mimeType != null
            ? SettableMetadata(contentType: mimeType)
            : null;

        uploadTask = ref.putFile(file, metadata);
      }

      // Listen to upload progress if callback is provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException('Firebase Storage error: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to upload file: $e');
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      // If path contains slashes, split it and use child() multiple times
      // Otherwise, treat it as a single path segment
      final pathParts = path.split('/');
      Reference ref = firebaseStorage.ref();
      for (final part in pathParts) {
        if (part.isNotEmpty) {
          ref = ref.child(part);
        }
      }
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException('Firebase Storage error: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to delete file: $e');
    }
  }

  @override
  Future<void> deleteFileByUrl(String downloadUrl) async {
    try {
      // Use refFromURL to get a reference directly from the download URL
      final ref = firebaseStorage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException('Firebase Storage error: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to delete file from URL: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    try {
      return await firebaseStorage.ref().child(path).getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException('Firebase Storage error: ${e.message}');
    } catch (e) {
      throw StorageException('Failed to get download URL: $e');
    }
  }
}

