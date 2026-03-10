import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class PdfViewerScreen extends StatefulWidget {
  final String? assetPath;
  final String? pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    this.assetPath,
    this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _noPdfAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Check if both paths are null or empty
      if ((widget.pdfUrl == null || widget.pdfUrl!.isEmpty) &&
          (widget.assetPath == null || widget.assetPath!.isEmpty)) {
        setState(() {
          _noPdfAvailable = true;
          _isLoading = false;
        });
        return;
      }

      if (widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty) {
        await _loadPdfFromUrl(widget.pdfUrl!);
      } else if (widget.assetPath != null && widget.assetPath!.isNotEmpty) {
        await _loadPdfFromAssets(widget.assetPath!);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading PDF: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPdfFromAssets(String assetPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/asset_pdf.pdf');

      // Use the Flutter asset bundle to load the PDF
      final data = await DefaultAssetBundle.of(context).load(assetPath);
      final bytes = data.buffer.asUint8List();

      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading asset PDF: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPdfFromUrl(String url) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create a unique filename for this PDF
      final filename = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');

      // Download the PDF
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Write the PDF to temporary file
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to download PDF: HTTP ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error downloading PDF: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!_isLoading && !_hasError && !_noPdfAvailable)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Implement PDF sharing functionality
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Sharing PDF...')));
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    } else if (_noPdfAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No PDF has been added yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'There\'s no document available to view',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadPdf, child: const Text('Try Again')),
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            child: PDFView(
              filePath: _localPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,

              onRender: (pages) {
                setState(() {
                  _totalPages = pages!;
                });
              },
              onError: (error) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.toString();
                });
              },
              onPageError: (page, error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading page $page: $error')),
                );
              },
              onPageChanged: (page, _) {
                setState(() {
                  _currentPage = page!;
                });
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Page ${_currentPage + 1} of $_totalPages',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
