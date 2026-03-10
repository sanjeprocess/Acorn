import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/document_file_model.dart';
import '../services/document_api_service.dart';

class DocumentRepository {
  final DocumentApiService _apiService;

  DocumentRepository(this._apiService);

  /// Upload PDF documents
  Future<List<String>> uploadDocuments({
    required String travelId,
    required String documentType,
    required List<File> pdfFiles,
    Function(double)? onProgress,
  }) async {
    try {
      final route = _uploadRouteFor(documentType);
      if (route == null) {
        throw DocumentException('Invalid document type: $documentType');
      }
      log(
        '[DOC_UPLOAD] type=$documentType -> field=${route.fieldName}, files=${pdfFiles.map((f) => f.path.split('/').last).toList()}',
      );

      final response = await _apiService.uploadDocuments(
        travelId: travelId,
        fieldName: route.fieldName,
        filenamePrefix: route.filenamePrefix,
        files: pdfFiles,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );
      return _extractUrls(response);
    } on DioException catch (e) {
      log('Repository error uploading documents: ${e.message}');
      throw DocumentException('Failed to upload documents: ${e.message}');
    } catch (e) {
      log('Repository unexpected error uploading documents: $e');
      throw DocumentException('Failed to upload documents: $e');
    }
  }

  List<String> _extractUrls(dynamic payload) {
    final urls = <String>{};

    void collect(dynamic node) {
      if (node is String) {
        final value = node.trim();
        if (value.startsWith('http://') || value.startsWith('https://')) {
          urls.add(value);
        }
        return;
      }
      if (node is Map) {
        for (final value in node.values) {
          collect(value);
        }
        return;
      }
      if (node is Iterable) {
        for (final item in node) {
          collect(item);
        }
      }
    }

    collect(payload);
    return urls.toList();
  }

  _UploadRoute? _uploadRouteFor(String documentType) {
    const mapping = {
      'Travel Insurance': _UploadRoute(fieldName: 'insurance'),
      'Vaccinate Certificate': _UploadRoute(fieldName: 'vaccinate'),
      'Emergency Contact': _UploadRoute(fieldName: 'emergency'),
      'Destination Information': _UploadRoute(fieldName: 'destinationInfo'),
      // Stored under insurance with virtual prefixes for backend compatibility.
      'Passport': _UploadRoute(
        fieldName: 'insurance',
        filenamePrefix: 'passport__',
      ),
      'Others': _UploadRoute(
        fieldName: 'insurance',
        filenamePrefix: 'others__',
      ),
    };
    final direct = mapping[documentType];
    if (direct != null) return direct;

    // Production backend currently rejects unknown multipart field names.
    // Route custom types through insurance with a category prefix.
    final safePrefix = documentType
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return _UploadRoute(
      fieldName: 'insurance',
      filenamePrefix: safePrefix.isEmpty ? 'custom__' : '${safePrefix}__',
    );
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String travelId,
    required String documentType,
    required DocumentFileModel document,
  }) async {
    try {
      final success = await _apiService.deleteDocument(
        travelId: travelId,
        fieldName: documentType,
        documentUrl: document.url,
      );

      if (!success) {
        throw DocumentException('Failed to delete document');
      }
    } on DioException catch (e) {
      log('Repository error deleting document: ${e.message}');
      throw DocumentException('Failed to delete document: ${e.message}');
    } catch (e) {
      log('Repository unexpected error deleting document: $e');
      throw DocumentException('Failed to delete document: $e');
    }
  }

  /// Parse document URLs from server response
  List<DocumentFileModel> _parseDocumentUrls(dynamic documentData) {
    List<DocumentFileModel> documents = [];

    if (documentData is List) {
      for (var item in documentData) {
        if (item is String) {
          // Handle URL string format
          documents.add(_createDocumentFromUrl(item));
        } else if (item is Map<String, dynamic>) {
          // Handle object format
          documents.add(DocumentFileModel.fromJson(item));
        }
      }
    }

    return documents;
  }

  /// Create DocumentFile from URL
  DocumentFileModel _createDocumentFromUrl(String url) {
    // Extract filename from URL
    String fileName = url.split('/').last;
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }

    // Extract extension
    String extension = fileName.split('.').last.toLowerCase();

    return DocumentFileModel(
      name: fileName,
      path: '',
      size: 0, // Size unknown from URL
      extension: extension,
      uploadTime: DateTime.now(), // Unknown upload time
      url: url,
    );
  }
}

class _UploadRoute {
  final String fieldName;
  final String? filenamePrefix;

  const _UploadRoute({required this.fieldName, this.filenamePrefix});
}

/// Custom exception for document operations
class DocumentException implements Exception {
  final String message;

  DocumentException(this.message);

  @override
  String toString() => 'DocumentException: $message';
}
