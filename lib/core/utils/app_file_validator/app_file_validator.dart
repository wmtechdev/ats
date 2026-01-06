import 'package:file_picker/file_picker.dart';

class AppFileValidator {
  AppFileValidator._();

  // Maximum file size: 20MB
  static const int maxFileSizeBytes = 20 * 1024 * 1024;

  // Allowed file extensions - PDF only
  static const List<String> allowedExtensions = [
    'pdf',
  ];

  // Allowed MIME types - PDF only
  static const List<String> allowedMimeTypes = [
    'application/pdf',
  ];

  /// Validates a file from file picker
  /// Returns null if valid, error message if invalid
  static String? validateFile(PlatformFile file) {
    // Check if file has bytes or path
    if (file.bytes == null && file.path == null) {
      return 'File is invalid or corrupted';
    }

    // Check file size
    final fileSize = file.size;
    if (fileSize == 0) {
      return 'File is empty';
    }

    if (fileSize > maxFileSizeBytes) {
      final maxSizeMB = maxFileSizeBytes / (1024 * 1024);
      return 'File size exceeds maximum allowed size of ${maxSizeMB.toInt()}MB';
    }

    // Check file extension
    final extension = _getFileExtension(file.name);
    if (extension == null || extension.isEmpty) {
      return 'File must have a valid extension';
    }

    if (!allowedExtensions.contains(extension.toLowerCase())) {
      return 'Only PDF files are allowed. Please upload a PDF document.';
    }

    // Check MIME type if available
    if (file.extension != null) {
      final mimeType = _getMimeTypeFromExtension(file.extension!);
      if (mimeType != null && !allowedMimeTypes.contains(mimeType)) {
        return 'Only PDF files are allowed. Please upload a PDF document.';
      }
    }

    return null;
  }

  /// Validates file size only
  static String? validateFileSize(int sizeInBytes) {
    if (sizeInBytes == 0) {
      return 'File is empty';
    }

    if (sizeInBytes > maxFileSizeBytes) {
      final maxSizeMB = maxFileSizeBytes / (1024 * 1024);
      return 'File size exceeds maximum allowed size of ${maxSizeMB.toInt()}MB';
    }

    return null;
  }

  /// Validates file extension only
  static String? validateFileExtension(String fileName) {
    final extension = _getFileExtension(fileName);
    if (extension == null || extension.isEmpty) {
      return 'File must have a valid extension';
    }

    if (!allowedExtensions.contains(extension.toLowerCase())) {
      return 'Only PDF files are allowed. Please upload a PDF document.';
    }

    return null;
  }

  /// Sanitizes file name by removing special characters
  static String sanitizeFileName(String fileName) {
    // Remove path separators and special characters
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();

    // Ensure it's not empty
    if (sanitized.isEmpty) {
      return 'document_${DateTime.now().millisecondsSinceEpoch}';
    }

    return sanitized;
  }

  /// Gets file extension from file name
  static String? _getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1 || lastDot == fileName.length - 1) {
      return null;
    }
    return fileName.substring(lastDot + 1);
  }

  /// Gets MIME type from file extension
  static String? _getMimeTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }

  /// Formats file size to human-readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Extracts the original filename from a document name that may contain Firebase ID prefix
  /// Document names are stored as: ${userId}_${restOfTheName}
  /// Example: 2eToQufVj4WNXjbV4AuTJ2D41CH3_Resume_Muhammad_Mubeen_Bhatti_Resume_Flutter_Developer.pdf
  /// Returns: Resume_Muhammad_Mubeen_Bhatti_Resume_Flutter_Developer.pdf
  /// This function removes only the userId (first segment), keeping the rest
  static String extractOriginalFileName(String documentName) {
    if (documentName.isEmpty) {
      return documentName;
    }

    // Split by underscore
    final parts = documentName.split('_');
    
    // If there's only one part or empty, return as is
    if (parts.length <= 1) {
      return documentName;
    }
    
    // Remove the first segment (userId) and join the rest
    return parts.sublist(1).join('_');
  }
}

