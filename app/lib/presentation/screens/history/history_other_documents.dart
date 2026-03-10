import 'dart:developer';
import 'package:arcon_travel_app/data/repositories/travels_repository.dart';
import 'package:arcon_travel_app/domain/entities/travel_entity.dart';
import 'package:arcon_travel_app/presentation/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../data/models/document_file_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/document_section.dart';
import '../../widgets/pdf_view_widget.dart';

class HistoryOtherDocumentsScreen extends StatefulWidget {
  final TravelEntity travel;

  const HistoryOtherDocumentsScreen({super.key, required this.travel});

  @override
  State<HistoryOtherDocumentsScreen> createState() =>
      _HistoryOtherDocumentsScreenState();
}

class _HistoryOtherDocumentsScreenState
    extends State<HistoryOtherDocumentsScreen> {
  static const String _passportPrefix = 'passport__';
  static const String _othersPrefix = 'others__';
  final Set<String> _passportUrlHints = <String>{};
  final Set<String> _othersUrlHints = <String>{};
  final Map<String, String> _urlExtensionHints = <String, String>{};

  // Document categories and their uploaded files
  final Map<String, List<DocumentFileModel>> _documents = {
    'Travel Insurance': [],
    'Vaccinate Certificate': [],
    'Emergency Contact': [],
    'Destination Information': [],
    'Passport': [],
    'Others': [],
  };
  static const Map<String, String> _fieldToCategory = {
    'insurance': 'Travel Insurance',
    'vaccinate': 'Vaccinate Certificate',
    'emergency': 'Emergency Contact',
    'destinationInfo': 'Destination Information',
    'passport': 'Passport',
    'others': 'Others',
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bootstrapDocumentState();
  }

  Future<void> _bootstrapDocumentState() async {
    _passportUrlHints.clear();
    _othersUrlHints.clear();
    _urlExtensionHints.clear();
    await _loadLocalCategoryHints();
    await _loadExistingDocuments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Load existing documents from server
  Future<void> _loadExistingDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.travel.otherDocs != null) {
        final data = widget.travel.otherDocs ?? {};
        final nextDocs = <String, List<DocumentFileModel>>{
          'Travel Insurance': [],
          'Vaccinate Certificate': [],
          'Emergency Contact': [],
          'Destination Information': [],
          'Passport': [],
          'Others': [],
        };

        for (final entry in data.entries) {
          final field = entry.key?.toString() ?? '';
          if (field.isEmpty) continue;
          final docs = _parseDocumentUrls(entry.value);

          if (field == 'insurance') {
            final insuranceDocs = <DocumentFileModel>[];
            final passportDocs = <DocumentFileModel>[];
            final othersDocs = <DocumentFileModel>[];

            for (final doc in docs) {
              if (_isPrefixed(doc, _passportPrefix)) {
                passportDocs.add(_formatVirtualCategoryDoc(doc, 'passport'));
              } else if (_isPrefixed(doc, _othersPrefix)) {
                othersDocs.add(_formatVirtualCategoryDoc(doc, 'others'));
              } else if (_matchesUrlHint(doc, _passportUrlHints)) {
                passportDocs.add(_formatVirtualCategoryDoc(doc, 'passport'));
              } else if (_matchesUrlHint(doc, _othersUrlHints)) {
                othersDocs.add(_formatVirtualCategoryDoc(doc, 'others'));
              } else {
                insuranceDocs.add(_stripVirtualPrefix(doc));
              }
            }

            nextDocs['Travel Insurance'] = _mergeDocuments(
              nextDocs['Travel Insurance'] ?? const [],
              insuranceDocs,
            );
            nextDocs['Passport'] = _mergeDocuments(
              nextDocs['Passport'] ?? const [],
              passportDocs,
            );
            nextDocs['Others'] = _mergeDocuments(
              nextDocs['Others'] ?? const [],
              othersDocs,
            );
            continue;
          }

          final category = _categoryForField(field);
          nextDocs[category] = _mergeDocuments(
            nextDocs[category] ?? const [],
            docs,
          );
        }

        setState(() {
          _documents
            ..clear()
            ..addAll(nextDocs);
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showSnackBar('Error loading documents: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _categoryForField(String field) {
    final normalized = field.trim();
    if (normalized.isEmpty) return field;
    final existing = _fieldToCategory[normalized];
    if (existing != null) return existing;
    final spaced = normalized.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return spaced
        .split(RegExp(r'[\s_\-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  // Parse document URLs from server response
  List<DocumentFileModel> _parseDocumentUrls(dynamic documentData) {
    List<DocumentFileModel> documents = [];

    if (documentData is List) {
      for (var item in documentData) {
        if (item is String) {
          // Handle URL string format
          documents.add(_createDocumentFromUrl(item));
        } else if (item is Map<String, dynamic>) {
          // Handle object format
          final baseDocument = DocumentFileModel.fromJson(item);
          final normalizedName = _stripVirtualPrefixFromName(
            baseDocument.name.isNotEmpty
                ? baseDocument.name
                : _extractFileNameFromUrl(baseDocument.url),
          );
          documents.add(baseDocument.copyWith(name: normalizedName));
        }
      }
    }

    return documents;
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

  void _rememberUrlHints(List<DocumentFileModel> docs, Set<String> target) {
    for (final doc in docs) {
      if (doc.url.isNotEmpty) {
        target.add(_normalizedUrl(doc.url));
      }
    }
  }

  String _normalizedUrl(String url) => url.split('?').first.trim();

  bool _matchesUrlHint(DocumentFileModel doc, Set<String> hints) {
    if (hints.isEmpty || doc.url.isEmpty) return false;
    return hints.contains(_normalizedUrl(doc.url));
  }

  // Create DocumentFile from URL
  DocumentFileModel _createDocumentFromUrl(String url) {
    // Extract filename from URL
    String fileName = url.split('/').last;
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }

    String extension = _extensionForUrl(url, fallbackFileName: fileName);
    fileName = _normalizeNameWithHintedExtension(fileName, extension);

    DocumentFileModel documentFileMOdel = DocumentFileModel(
      name: _stripVirtualPrefixFromName(fileName),
      path: '',
      size: 0, // Size unknown from URL
      extension: extension,
      uploadTime: DateTime.now(), // Unknown upload time
      url: url,
    );

    _attachDocumentActions(documentFileMOdel);

    return documentFileMOdel;
  }

  bool _isPrefixed(DocumentFileModel doc, String prefix) {
    final fileName =
        doc.name.isNotEmpty ? doc.name : _extractFileNameFromUrl(doc.url);
    return fileName.startsWith(prefix);
  }

  String _extractFileNameFromUrl(String url) {
    String fileName = url.split('/').last;
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }
    return fileName;
  }

  String _extensionForUrl(String url, {required String fallbackFileName}) {
    final hinted = _urlExtensionHints[_normalizedUrl(url)];
    if (hinted != null && hinted.isNotEmpty) return hinted;
    return fallbackFileName.split('.').last.toLowerCase();
  }

  String _normalizeNameWithHintedExtension(String fileName, String extension) {
    final dotIndex = fileName.lastIndexOf('.');
    final base = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
    return '$base.$extension';
  }

  DocumentFileModel _stripVirtualPrefix(DocumentFileModel doc) {
    return doc.copyWith(name: _stripVirtualPrefixFromName(doc.name));
  }

  DocumentFileModel _formatVirtualCategoryDoc(
    DocumentFileModel doc,
    String categoryPrefix,
  ) {
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
    _attachDocumentActions(formatted);
    return formatted;
  }

  String _stripVirtualPrefixFromName(String name) {
    if (name.startsWith(_passportPrefix)) {
      return name.substring(_passportPrefix.length);
    }
    if (name.startsWith(_othersPrefix)) {
      return name.substring(_othersPrefix.length);
    }
    return name;
  }

  void _attachDocumentActions(DocumentFileModel document) {
    document.onTap = () => _viewDocument(document);
  }

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

  // Refresh documents from server after upload
  Future<void> _refreshDocuments() async {
    final authRepo = locator<AuthRepository>();
    final travelRepo = locator<TravelsRepository>();
    final user = await authRepo.getCurrentUser();
    log(user!.id);
    try {
      // Make API call to get updated travel data
      final travelList = await travelRepo.getUserTavelData(user.id);

      TravelEntity travel =
          travelList
              .where((travel) => travel.travelId == widget.travel.travelId)
              .map((travel) => TravelEntity.fromModel(travel))
              .toList()[0];

      // Update the travel entity with new data
      if (travel.otherDocs != null) {
        final data = travel.otherDocs ?? {};
        final nextDocs = <String, List<DocumentFileModel>>{
          'Travel Insurance': [],
          'Vaccinate Certificate': [],
          'Emergency Contact': [],
          'Destination Information': [],
          'Passport': [],
          'Others': [],
        };

        for (final entry in data.entries) {
          final field = entry.key?.toString() ?? '';
          if (field.isEmpty) continue;
          final docs = _parseDocumentUrls(entry.value);

          if (field == 'insurance') {
            final insuranceDocs = <DocumentFileModel>[];
            final passportDocs = <DocumentFileModel>[];
            final othersDocs = <DocumentFileModel>[];

            for (final doc in docs) {
              if (_isPrefixed(doc, _passportPrefix)) {
                passportDocs.add(_formatVirtualCategoryDoc(doc, 'passport'));
              } else if (_isPrefixed(doc, _othersPrefix)) {
                othersDocs.add(_formatVirtualCategoryDoc(doc, 'others'));
              } else if (_matchesUrlHint(doc, _passportUrlHints)) {
                passportDocs.add(_formatVirtualCategoryDoc(doc, 'passport'));
              } else if (_matchesUrlHint(doc, _othersUrlHints)) {
                othersDocs.add(_formatVirtualCategoryDoc(doc, 'others'));
              } else {
                insuranceDocs.add(_stripVirtualPrefix(doc));
              }
            }

            nextDocs['Travel Insurance'] = _mergeDocuments(
              nextDocs['Travel Insurance'] ?? const [],
              insuranceDocs,
            );
            nextDocs['Passport'] = _mergeDocuments(
              nextDocs['Passport'] ?? const [],
              passportDocs,
            );
            nextDocs['Others'] = _mergeDocuments(
              nextDocs['Others'] ?? const [],
              othersDocs,
            );
            continue;
          }

          final category = _categoryForField(field);
          nextDocs[category] = _mergeDocuments(
            nextDocs[category] ?? const [],
            docs,
          );
        }

        setState(() {
          _documents
            ..clear()
            ..addAll(nextDocs);
        });
      }
    } catch (e) {
      log('Error refreshing documents: $e');
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDocumentSection(String title, List<DocumentFileModel> files) {
    return DocumentSectionWidget(title: title, files: files);
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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _refreshDocuments();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Instructions'),
                      content: const Text(
                        '1. Select document type from dropdown\n'
                        '2. Tap upload to select files (max 5 per category)\n'
                        '3. Scroll horizontally to view documents\n'
                        '4. Tap any file to view it\n'
                        '5. Long press any file to delete it\n'
                        '6. Supported formats: PDF, JPG, PNG, DOC, DOCX',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      children: [
                        const SizedBox(height: 16),
                        ..._documents.entries.map((entry) {
                          return _buildDocumentSection(entry.key, entry.value);
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// Image Viewer Screen for viewing images
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(fileName, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
