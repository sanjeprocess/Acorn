import 'dart:developer';
import 'dart:io';
import 'package:arcon_travel_app/core/constants/api_constant.dart';
import 'package:arcon_travel_app/data/services/api_service.dart';
import 'package:dio/dio.dart';

class DocumentApiService {
  final ApiService _apiService;

  DocumentApiService({required ApiService apiService})
    : _apiService = apiService;

  /// Upload PDF documents
  Future<Map<String, dynamic>> uploadDocuments({
    required String travelId,
    required String fieldName,
    required List<File> files,
    String? filenamePrefix,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      List<MultipartFile> uploadFiles = [];
      final preparedFileNames = <String>[];

      // Add files with accurate mime type based on extension.
      for (File file in files) {
        String fileName = file.path.split('/').last;
        if (filenamePrefix != null && filenamePrefix.isNotEmpty) {
          fileName = '$filenamePrefix$fileName';
        }
        preparedFileNames.add(fileName);
        uploadFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: _contentTypeFor(fileName),
          ),
        );
      }

      final formData = FormData.fromMap({
        'travelId': int.parse(travelId),
        fieldName: uploadFiles,
      });
      log(
        '[DOC_UPLOAD_API] travelId=$travelId field=$fieldName filenames=$preparedFileNames',
      );
      log(
        '[DOC_UPLOAD_API] form-fields=${formData.fields.map((e) => '${e.key}=${e.value}').toList()} form-files=${formData.files.map((e) => e.key).toList()}',
      );

      final response = await _apiService.post(
        ApiConstants.uploadDocuments,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Upload failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('Error uploading documents: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error uploading documents: $e');
      throw DioException(
        requestOptions: RequestOptions(path: '/travels/upload'),
        message: 'Unexpected error: $e',
      );
    }
  }

  DioMediaType _contentTypeFor(String fileName) {
    final lowered = fileName.toLowerCase();
    if (lowered.endsWith('.jpg') || lowered.endsWith('.jpeg')) {
      return DioMediaType('image', 'jpeg');
    }
    if (lowered.endsWith('.png')) {
      return DioMediaType('image', 'png');
    }
    if (lowered.endsWith('.pdf')) {
      return DioMediaType('application', 'pdf');
    }
    if (lowered.endsWith('.doc')) {
      return DioMediaType('application', 'msword');
    }
    if (lowered.endsWith('.docx')) {
      return DioMediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return DioMediaType('application', 'octet-stream');
  }

  /// Delete a document
  Future<bool> deleteDocument({
    required String travelId,
    required String fieldName,
    required String documentUrl,
  }) async {
    try {
      log('travle : $travelId');
      log('fieldName : $fieldName');
      log('documentUrl : $documentUrl');
      final response = await _apiService.delete(
        ApiConstants.deleteDocs,
        data: {'travelId': travelId, 'field': fieldName, 'url': documentUrl},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      log('Error deleting document: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error deleting document: $e');
      throw DioException(
        requestOptions: RequestOptions(path: '/docs'),
        message: 'Unexpected error: $e',
      );
    }
  }
}
