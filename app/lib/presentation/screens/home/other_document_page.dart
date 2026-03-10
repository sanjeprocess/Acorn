import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:arcon_travel_app/data/models/document_file_model.dart';
import 'package:arcon_travel_app/data/repositories/document_repository.dart';
import 'package:arcon_travel_app/data/repositories/travels_repository.dart';
import 'package:arcon_travel_app/domain/entities/travel_entity.dart';
import 'package:arcon_travel_app/presentation/widgets/custom_scaffold.dart';
import 'package:arcon_travel_app/presentation/widgets/document_section.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/pdf_view_widget.dart';
import '../../widgets/upload_section.dart';

// Constants
class DocumentConstants {
  static const int maxFilesPerCategory = 5;
  static const List<String> allowedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
  ];

  static const Map<String, String> fieldMapping = {
    'Travel Insurance': 'insurance',
    'Vaccinate Certificate': 'vaccinate',
    'Emergency Contact': 'emergency',
    'Destination Information': 'destinationInfo',
    // Passport/Others are virtual categories stored in insurance with prefixes.
    'Passport': 'insurance',
    'Others': 'insurance',
  };

  static const Map<String, String> fieldToCategory = {
    'insurance': 'Travel Insurance',
    'vaccinate': 'Vaccinate Certificate',
    'emergency': 'Emergency Contact',
    'destinationInfo': 'Destination Information',
    'passport': 'Passport',
    'others': 'Others',
  };

  static const String passportPrefix = 'passport__';
  static const String othersPrefix = 'others__';

  static const List<String> documentCategories = [
    'Travel Insurance',
    'Vaccinate Certificate',
    'Emergency Contact',
    'Destination Information',
    'Passport',
    'Others',
  ];

  static String categoryForField(String field) {
    final normalized = field.trim();
    if (normalized.isEmpty) return field;
    return fieldToCategory[normalized] ?? _humanizeField(normalized);
  }

  static String fieldForCategory(String category) {
    final normalized = category.trim();
    if (normalized.isEmpty) return category;
    return fieldMapping[normalized] ?? _toCamelCase(normalized);
  }

  static String _humanizeField(String field) {
    final spaced = field.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return spaced
        .split(RegExp(r'[\s_\-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String _toCamelCase(String value) {
    final parts =
        value
            .split(RegExp(r'[\s_\-]+'))
            .where((part) => part.isNotEmpty)
            .map((part) => part.toLowerCase())
            .toList();
    if (parts.isEmpty) return value;
    return parts.first +
        parts
            .skip(1)
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join();
  }
}

class OtherDocumentsScreen extends StatefulWidget {
  final TravelEntity travel;

  const OtherDocumentsScreen({super.key, required this.travel});

  @override
  State<OtherDocumentsScreen> createState() => _OtherDocumentsScreenState();
}

class _OtherDocumentsScreenState extends State<OtherDocumentsScreen> {
  // Dependencies
  late final DocumentRepository _documentRepository;
  late final AuthRepository _authRepository;
  late final TravelsRepository _travelRepository;

  // State variables
  final Map<String, List<DocumentFileModel>> _documents = {};
  String? _selectedDocumentType;
  bool _isUploading = false;
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isRefreshing = false;
  String? _loadingMessage;
  final Set<String> _passportNameHints = <String>{};
  final Set<String> _othersNameHints = <String>{};
  final Set<String> _passportUrlHints = <String>{};
  final Set<String> _othersUrlHints = <String>{};
  final Map<String, String> _urlExtensionHints = <String, String>{};

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _initializeDocumentCategories();
    _bootstrapDocumentState();
  }

  Future<void> _bootstrapDocumentState() async {
    _passportNameHints.clear();
    _othersNameHints.clear();
    _passportUrlHints.clear();
    _othersUrlHints.clear();
    _urlExtensionHints.clear();
    await _loadLocalCategoryHints();
    await _loadDocumentsFromServer();
  }

  void _initializeDependencies() {
    _documentRepository = locator<DocumentRepository>();
    _authRepository = locator<AuthRepository>();
    _travelRepository = locator<TravelsRepository>();
  }

  void _initializeDocumentCategories() {
    for (String category in DocumentConstants.documentCategories) {
      _documents[category] = [];
    }
  }

  // Document Loading Methods - Always from server
  Future<void> _loadDocumentsFromServer() async {
    if (!mounted) return;

    _setLoading(true, 'Loading documents...');

    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        _showErrorSnackBar('User not found');
        return;
      }

      // Always fetch fresh data from server
      final travelList = await _travelRepository.getUserTavelData(user.id);
      log('My Travel : $travelList');
      final updatedTravel = _findTravelById(travelList, widget.travel.travelId);

      if (updatedTravel?.otherDocs != null) {
        _parseAndSetDocuments(updatedTravel!.otherDocs!);
      } else {
        // Clear documents if no data found
        _clearAllDocuments();
      }
    } catch (e) {
      _handleError('Error loading documents from server', e);
    } finally {
      _setLoading(false);
    }
  }

  void _clearAllDocuments() {
    setState(() {
      _documents
        ..clear()
        ..addEntries(
          DocumentConstants.documentCategories.map(
            (category) => MapEntry(category, []),
          ),
        );
    });
  }

  void _parseAndSetDocuments(Map<dynamic, dynamic> otherDocs) {
    final updatedDocs = <String, List<DocumentFileModel>>{
      for (final category in DocumentConstants.documentCategories) category: [],
    };

    for (final entry in otherDocs.entries) {
      final rawField = entry.key?.toString() ?? '';
      final category = DocumentConstants.categoryForField(rawField);
      final docs = _parseDocumentData(rawField, entry.value);

      if (rawField == 'insurance') {
        final insuranceDocs = <DocumentFileModel>[];
        final passportDocs = <DocumentFileModel>[];
        final othersDocs = <DocumentFileModel>[];

        for (final doc in docs) {
          if (_isPrefixed(doc, DocumentConstants.passportPrefix)) {
            passportDocs.add(
              _formatVirtualCategoryDoc(
                doc,
                categoryPrefix: 'passport',
                categoryLabel: 'Passport',
              ),
            );
          } else if (_isPrefixed(doc, DocumentConstants.othersPrefix)) {
            othersDocs.add(
              _formatVirtualCategoryDoc(
                doc,
                categoryPrefix: 'others',
                categoryLabel: 'Others',
              ),
            );
          } else if (_matchesUrlHint(doc, _passportUrlHints)) {
            passportDocs.add(
              _formatVirtualCategoryDoc(
                doc,
                categoryPrefix: 'passport',
                categoryLabel: 'Passport',
              ),
            );
          } else if (_matchesUrlHint(doc, _othersUrlHints)) {
            othersDocs.add(
              _formatVirtualCategoryDoc(
                doc,
                categoryPrefix: 'others',
                categoryLabel: 'Others',
              ),
            );
          } else {
            insuranceDocs.add(_stripVirtualPrefix(doc));
          }
        }

        updatedDocs['Travel Insurance'] = _mergeDocuments(
          updatedDocs['Travel Insurance'] ?? const [],
          insuranceDocs,
        );
        updatedDocs['Passport'] = _mergeDocuments(
          updatedDocs['Passport'] ?? const [],
          passportDocs,
        );
        updatedDocs['Others'] = _mergeDocuments(
          updatedDocs['Others'] ?? const [],
          othersDocs,
        );
        continue;
      }

      updatedDocs[category] = _mergeDocuments(
        updatedDocs[category] ?? const [],
        docs,
      );
    }

    setState(() {
      _documents
        ..clear()
        ..addAll(updatedDocs);
    });
  }

  List<DocumentFileModel> _mergeDocuments(
    List<DocumentFileModel> a,
    List<DocumentFileModel> b,
  ) {
    final merged = <DocumentFileModel>[];
    final seen = <String>{};
    for (final doc in [...a, ...b]) {
      final key = doc.url;
      if (key.isEmpty || !seen.contains(key)) {
        merged.add(doc);
        if (key.isNotEmpty) {
          seen.add(key);
        }
      }
    }
    return merged;
  }

  List<DocumentFileModel> _parseDocumentData(
    String category,
    dynamic documentData,
  ) {
    if (documentData == null) return [];

    List<DocumentFileModel> documents = [];

    if (documentData is List) {
      for (var item in documentData) {
        DocumentFileModel? document = _createDocumentFromItem(item, category);
        if (document != null) {
          documents.add(document);
        }
      }
    }

    return documents;
  }

  DocumentFileModel? _createDocumentFromItem(dynamic item, String category) {
    try {
      if (item is String) {
        return _createDocumentFromUrl(item, category);
      } else if (item is Map<String, dynamic>) {
        return _createDocumentFromJson(item, category);
      }
    } catch (e) {
      log('Error creating document from item: $e');
    }
    return null;
  }

  DocumentFileModel _createDocumentFromUrl(String url, String category) {
    String fileName = _extractFileNameFromUrl(url);
    String extension = _extensionForUrl(url, fallbackFileName: fileName);
    fileName = _normalizeNameWithHintedExtension(fileName, extension);

    DocumentFileModel document = DocumentFileModel(
      name: _stripVirtualPrefixFromName(fileName),
      path: '',
      size: 0,
      extension: extension,
      uploadTime: DateTime.now(),
      url: url,
    );

    _attachDocumentActions(document, category);
    return document;
  }

  DocumentFileModel _createDocumentFromJson(
    Map<String, dynamic> json,
    String category,
  ) {
    final baseDocument = DocumentFileModel.fromJson(json);
    final normalizedName = _stripVirtualPrefixFromName(
      baseDocument.name.isNotEmpty
          ? baseDocument.name
          : _extractFileNameFromUrl(baseDocument.url),
    );
    DocumentFileModel document = baseDocument.copyWith(name: normalizedName);
    _attachDocumentActions(document, category);
    return document;
  }

  bool _isPrefixed(DocumentFileModel doc, String prefix) {
    final name =
        doc.name.isNotEmpty ? doc.name : _extractFileNameFromUrl(doc.url);
    return name.startsWith(prefix);
  }

  bool _matchesHint(DocumentFileModel doc, Set<String> hints) {
    if (hints.isEmpty) return false;
    return hints.contains(_normalizedFileName(doc.name));
  }

  bool _matchesUrlHint(DocumentFileModel doc, Set<String> hints) {
    if (hints.isEmpty || doc.url.isEmpty) return false;
    return hints.contains(_normalizedUrl(doc.url));
  }

  void _rememberHints(List<DocumentFileModel> docs, Set<String> target) {
    for (final doc in docs) {
      target.add(_normalizedFileName(doc.name));
    }
  }

  void _rememberUrlHints(List<DocumentFileModel> docs, Set<String> target) {
    for (final doc in docs) {
      if (doc.url.isNotEmpty) {
        target.add(_normalizedUrl(doc.url));
      }
    }
  }

  String _normalizedFileName(String name) => name.trim().toLowerCase();

  String _normalizedUrl(String url) => url.split('?').first.trim();

  DocumentFileModel _stripVirtualPrefix(DocumentFileModel doc) {
    return doc.copyWith(name: _stripVirtualPrefixFromName(doc.name));
  }

  DocumentFileModel _formatVirtualCategoryDoc(
    DocumentFileModel doc, {
    required String categoryPrefix,
    required String categoryLabel,
  }) {
    final normalizedPrefix = categoryPrefix.trim().toLowerCase();
    final sourceName =
        doc.name.isNotEmpty ? doc.name : _extractFileNameFromUrl(doc.url);
    final stripped = _stripVirtualPrefixFromName(sourceName);
    final lowered = stripped.toLowerCase();

    String renamed = stripped;
    if (lowered.startsWith('$normalizedPrefix-')) {
      renamed = stripped;
    } else if (lowered.startsWith('insurance-')) {
      renamed = '$normalizedPrefix-${stripped.substring('insurance-'.length)}';
    } else {
      renamed = '$normalizedPrefix-$stripped';
    }

    final formatted = DocumentFileModel(
      name: renamed,
      path: doc.path,
      size: doc.size,
      extension: doc.extension,
      uploadTime: doc.uploadTime,
      url: doc.url,
    );
    _attachDocumentActions(formatted, categoryLabel);
    return formatted;
  }

  String _stripVirtualPrefixFromName(String name) {
    if (name.startsWith(DocumentConstants.passportPrefix)) {
      return name.substring(DocumentConstants.passportPrefix.length);
    }
    if (name.startsWith(DocumentConstants.othersPrefix)) {
      return name.substring(DocumentConstants.othersPrefix.length);
    }
    return name;
  }

  void _attachDocumentActions(DocumentFileModel document, String category) {
    document.onTap = () => _viewDocument(document);
    document.longTap = () => _showDeleteConfirmation(category, document);
  }

  String _extractFileNameFromUrl(String url) {
    String fileName = url.split('/').last;
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }
    return fileName;
  }

  String _extractExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  String _extensionForUrl(String url, {required String fallbackFileName}) {
    final hinted = _urlExtensionHints[_normalizedUrl(url)];
    if (hinted != null && hinted.isNotEmpty) return hinted;
    return _extractExtension(fallbackFileName);
  }

  String _normalizeNameWithHintedExtension(String fileName, String extension) {
    final dotIndex = fileName.lastIndexOf('.');
    final base = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
    return '$base.$extension';
  }

  TravelEntity? _findTravelById(List<dynamic> travelList, int travelId) {
    try {
      final matchingTravel = travelList.firstWhere(
        (travel) => travel.travelId == travelId,
      );
      return TravelEntity.fromModel(matchingTravel);
    } catch (e) {
      return null;
    }
  }

  // Document Refresh Methods
  Future<void> _refreshDocuments() async {
    if (!mounted) return;

    _setRefreshing(true);

    try {
      await _loadDocumentsFromServer();
      _showSuccessSnackBar('Documents refreshed successfully');
    } catch (e) {
      _handleError('Error refreshing documents', e);
    } finally {
      _setRefreshing(false);
    }
  }

  // Upload Methods
  Future<void> _handleUpload() async {
    if (!_validateUploadConditions()) return;

    _setUploading(true);
    await _pickAndUploadFiles();
  }

  bool _validateUploadConditions() {
    if (_selectedDocumentType == null) {
      _showErrorSnackBar('Please select a document type first');
      return false;
    }

    final currentFiles = _documents[_selectedDocumentType!] ?? [];
    if (currentFiles.length >= DocumentConstants.maxFilesPerCategory) {
      _showErrorSnackBar(
        'Maximum ${DocumentConstants.maxFilesPerCategory} files allowed per category',
      );
      return false;
    }

    return true;
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: DocumentConstants.allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        if (_willExceedFileLimit(result.files.length)) return;
        await _uploadSelectedFiles(result.files);
      }
    } catch (e) {
      _handleError('Error picking files', e);
    } finally {
      _setUploading(false);
    }
  }

  bool _willExceedFileLimit(int newFilesCount) {
    final currentCount = _documents[_selectedDocumentType!]?.length ?? 0;
    if (currentCount + newFilesCount > DocumentConstants.maxFilesPerCategory) {
      final remainingSlots =
          DocumentConstants.maxFilesPerCategory - currentCount;
      _showErrorSnackBar(
        'Can only upload $remainingSlots more file(s) for this category',
      );
      return true;
    }
    return false;
  }

  Future<void> _uploadSelectedFiles(List<PlatformFile> files) async {
    if (!mounted) return;

    try {
      final selectedType = _selectedDocumentType!;
      final beforeVirtualUrls = _collectVirtualInsuranceUrls();

      // Show upload progress
      _setLoadingMessage('Uploading ${files.length} file(s)...');
      log(
        '[DOC_UPLOAD_UI] selectedType=$_selectedDocumentType files=${files.map((f) => f.name).toList()}',
      );

      final uploadedUrls = await _documentRepository.uploadDocuments(
        travelId: widget.travel.travelId.toString(),
        documentType: selectedType,
        pdfFiles: files.map((file) => File(file.path!)).toList(),
      );

      // Always reload from server after upload
      _setLoadingMessage('Loading updated documents...');
      await _loadDocumentsFromServer();

      final afterVirtualUrls = _collectVirtualInsuranceUrls();
      final inferredNewUrls = afterVirtualUrls.difference(beforeVirtualUrls);

      _rememberUploadedUrlsByCategory(selectedType, uploadedUrls);
      _rememberUploadedUrlsByCategory(selectedType, inferredNewUrls.toList());
      _tagMostRecentInsuranceUrls(selectedType, files.length);
      _rememberUploadedExtensionHints(selectedType, files);
      await _persistLocalCategoryHints();

      if (_isVirtualCategory(selectedType) && inferredNewUrls.isNotEmpty) {
        // Rebuild sections after URL-hint classification is updated.
        await _loadDocumentsFromServer();
      }

      _resetUploadState();
      _showSuccessSnackBar('${files.length} file(s) uploaded successfully!');
    } catch (e) {
      _handleError('Upload failed', e);
    }
  }

  void _resetUploadState() {
    setState(() {
      _selectedDocumentType = null;
    });
  }

  void _rememberUploadedUrlsByCategory(String category, List<String> urls) {
    final normalizedCategory = category.trim();
    final normalizedUrls =
        urls
            .map((url) => _normalizedUrl(url))
            .where((url) => url.isNotEmpty)
            .toSet();

    if (normalizedCategory == 'Passport') {
      _passportUrlHints.addAll(normalizedUrls);
      return;
    }

    const travelFields = {
      'Travel Insurance',
      'Vaccinate Certificate',
      'Emergency Contact',
      'Destination Information',
    };
    if (normalizedCategory == 'Others' ||
        !travelFields.contains(normalizedCategory)) {
      _othersUrlHints.addAll(normalizedUrls);
    }
  }

  bool _isVirtualCategory(String category) =>
      category.trim() == 'Passport' || category.trim() == 'Others';

  Set<String> _collectVirtualInsuranceUrls() {
    final categories = ['Travel Insurance', 'Passport', 'Others'];
    final urls = <String>{};
    for (final category in categories) {
      for (final doc in (_documents[category] ?? const <DocumentFileModel>[])) {
        if (doc.url.isNotEmpty) {
          urls.add(_normalizedUrl(doc.url));
        }
      }
    }
    return urls;
  }

  void _tagMostRecentInsuranceUrls(String category, int uploadedCount) {
    if (!_isVirtualCategory(category) || uploadedCount <= 0) return;
    final insuranceDocs = List<DocumentFileModel>.from(
      _documents['Travel Insurance'] ?? const <DocumentFileModel>[],
    );
    if (insuranceDocs.isEmpty) return;

    final start = math.max(insuranceDocs.length - uploadedCount, 0);
    final recentDocs = insuranceDocs.sublist(start);
    final target =
        category.trim() == 'Passport' ? _passportUrlHints : _othersUrlHints;
    for (final doc in recentDocs) {
      if (doc.url.isNotEmpty) {
        target.add(_normalizedUrl(doc.url));
      }
    }
  }

  void _rememberUploadedExtensionHints(
    String category,
    List<PlatformFile> files,
  ) {
    if (!_isVirtualCategory(category) || files.isEmpty) return;
    final insuranceDocs = List<DocumentFileModel>.from(
      _documents['Travel Insurance'] ?? const <DocumentFileModel>[],
    );
    if (insuranceDocs.isEmpty) return;

    final start = math.max(insuranceDocs.length - files.length, 0);
    final recentDocs = insuranceDocs.sublist(start);
    final extList =
        files
            .map((f) => _extractExtension(f.name))
            .where((ext) => ext.isNotEmpty)
            .toList();
    if (extList.isEmpty) return;

    for (var i = 0; i < recentDocs.length; i++) {
      final ext = extList[i < extList.length ? i : extList.length - 1];
      final url = recentDocs[i].url;
      if (url.isNotEmpty) {
        _urlExtensionHints[_normalizedUrl(url)] = ext;
      }
    }
  }

  // Delete Methods
  void _showDeleteConfirmation(String category, DocumentFileModel file) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete File'),
            content: Text('Are you sure you want to delete "${file.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  log('Category$category');
                  await _deleteDocument(category, file);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteDocument(String category, DocumentFileModel file) async {
    if (!mounted) return;

    _setDeleting(true);
    _setLoadingMessage('Deleting "${file.name}"...');

    try {
      await _documentRepository.deleteDocument(
        travelId: widget.travel.travelId.toString(),
        documentType: DocumentConstants.fieldForCategory(category),
        document: file,
      );
      if (file.url.isNotEmpty) {
        final normalized = _normalizedUrl(file.url);
        _passportUrlHints.remove(normalized);
        _othersUrlHints.remove(normalized);
        _urlExtensionHints.remove(normalized);
        await _persistLocalCategoryHints();
      }

      // Always reload from server after delete
      _setLoadingMessage('Loading updated documents...');
      await _loadDocumentsFromServer();

      _showSuccessSnackBar('File deleted successfully');
    } catch (e) {
      _handleError('Delete failed', e);
    } finally {
      _setDeleting(false);
    }
  }

  // Navigation Methods
  void _viewDocument(DocumentFileModel document) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _buildDocumentViewer(document)),
    );
  }

  Widget _buildDocumentViewer(DocumentFileModel document) {
    final isImage = [
      'jpg',
      'jpeg',
      'png',
    ].contains(document.extension.toLowerCase());

    if (isImage) {
      return ImageViewerScreen(
        imageUrl: document.url ?? '',
        fileName: document.name,
      );
    } else {
      return PdfViewerScreen(pdfUrl: document.url ?? '', title: document.name);
    }
  }

  // UI Helper Methods
  void _showInstructions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Instructions'),
            content: const Text(
              '1. Select document type from dropdown\n'
              '2. Tap upload to select files (max ${DocumentConstants.maxFilesPerCategory} per category)\n'
              '3. Scroll horizontally to view documents\n'
              '4. Tap any file to view it\n'
              '5. Long press any file to delete it\n'
              '6. Supported formats: PDF, JPG, JPEG, PNG, DOC, DOCX',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  Widget _buildUploadSection() {
    return UploadSection(
      selectedDocumentType: _selectedDocumentType,
      documents: _documents,
      isUploading: _isUploading,
      onDocumentTypeChanged: (String? newValue) {
        setState(() {
          _selectedDocumentType = newValue;
        });
      },
      onUploadPressed: _handleUpload,
    );
  }

  Widget _buildDocumentSection(String title, List<DocumentFileModel> files) {
    if (files.isEmpty) return const SizedBox.shrink();
    return DocumentSectionWidget(title: title, files: files);
  }

  List<Widget> _buildDocumentSections() {
    return _documents.entries
        .map((entry) => _buildDocumentSection(entry.key, entry.value))
        .toList();
  }

  // State Management Methods
  void _setLoading(bool loading, [String? message]) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        _loadingMessage = message;
      });
    }
  }

  void _setUploading(bool uploading) {
    if (mounted) {
      setState(() {
        _isUploading = uploading;
        if (uploading) {
          _loadingMessage = 'Preparing upload...';
        } else {
          _loadingMessage = null;
        }
      });
    }
  }

  void _setDeleting(bool deleting) {
    if (mounted) {
      setState(() {
        _isDeleting = deleting;
        if (!deleting) {
          _loadingMessage = null;
        }
      });
    }
  }

  void _setRefreshing(bool refreshing) {
    if (mounted) {
      setState(() {
        _isRefreshing = refreshing;
      });
    }
  }

  void _setLoadingMessage(String? message) {
    if (mounted) {
      setState(() {
        _loadingMessage = message;
      });
    }
  }

  String get _passportHintStorageKey =>
      'doc_hint_passport_${widget.travel.travelId}';
  String get _othersHintStorageKey =>
      'doc_hint_others_${widget.travel.travelId}';
  String get _extensionHintStorageKey =>
      'doc_hint_ext_${widget.travel.travelId}';

  Future<void> _loadLocalCategoryHints() async {
    final prefs = await SharedPreferences.getInstance();
    _passportUrlHints
      ..clear()
      ..addAll(prefs.getStringList(_passportHintStorageKey) ?? const []);
    _othersUrlHints
      ..clear()
      ..addAll(prefs.getStringList(_othersHintStorageKey) ?? const []);
    _urlExtensionHints
      ..clear()
      ..addAll(
        _decodeExtensionHints(prefs.getStringList(_extensionHintStorageKey)),
      );
  }

  Future<void> _persistLocalCategoryHints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _passportHintStorageKey,
      _passportUrlHints.toList(),
    );
    await prefs.setStringList(_othersHintStorageKey, _othersUrlHints.toList());
    await prefs.setStringList(
      _extensionHintStorageKey,
      _encodeExtensionHints(_urlExtensionHints),
    );
  }

  List<String> _encodeExtensionHints(Map<String, String> hints) {
    return hints.entries.map((e) => '${e.key}|${e.value}').toList();
  }

  Map<String, String> _decodeExtensionHints(List<String>? raw) {
    final map = <String, String>{};
    for (final item in raw ?? const <String>[]) {
      final index = item.lastIndexOf('|');
      if (index <= 0 || index >= item.length - 1) continue;
      final url = item.substring(0, index);
      final ext = item.substring(index + 1).toLowerCase();
      if (url.isNotEmpty && ext.isNotEmpty) {
        map[url] = ext;
      }
    }
    return map;
  }

  bool get _isAnyOperationInProgress =>
      _isLoading || _isUploading || _isDeleting;

  // Error Handling Methods
  void _handleError(String message, dynamic error) {
    log('$message: $error');
    _showErrorSnackBar('$message: ${error.toString()}');
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, isError: true);
  }

  void _showSuccessSnackBar(String message) {
    _showSnackBar(message, isError: false);
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor:
            isError
                ? const Color.fromARGB(255, 143, 10, 0)
                : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('My Documents'),
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed:
            _isAnyOperationInProgress
                ? null // Disable back button during operations
                : () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon:
              _isRefreshing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.refresh),
          onPressed: _isAnyOperationInProgress ? null : _refreshDocuments,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _isAnyOperationInProgress ? null : _showInstructions,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  _buildUploadSection(),
                  const SizedBox(height: 16),
                  ..._buildDocumentSections(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
        // Loading overlay
        if (_isAnyOperationInProgress) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _loadingMessage ?? 'Please wait...',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (_isUploading || _isDeleting) ...[
                  const SizedBox(height: 8),
                  Text(
                    'This may take a few moments',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Improved Image Viewer Screen
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String fileName;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: _buildImageViewer(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        fileName,
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: _buildLoadingIndicator,
          errorBuilder: _buildErrorWidget,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text('Loading image...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
