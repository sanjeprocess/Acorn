import 'package:arcon_travel_app/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/feedback_repository.dart';
import '../../../domain/entities/document_section_entity.dart';
import '../../../domain/entities/feedback_entity.dart';
import '../../../domain/entities/travel_entity.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/feedback_display_card.dart';
import '../../widgets/pdf_view_widget.dart';
import '../../widgets/trip_feedback_dialog.dart';
import 'history_other_documents.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String historyId;
  final TravelEntity travelEntity;

  const HistoryDetailScreen({
    super.key,
    required this.historyId,
    required this.travelEntity,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  // State variables
  bool _isLoading = true;
  bool _isSubmittingFeedback = false;
  late TravelEntity _travelEntity;
  FeedbackEntity? _feedbackEntity;

  // Dependencies
  late final AuthRepository _authRepo;
  late final FeedbackRepository _feedbackRepo;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _travelEntity = widget.travelEntity;
    _loadInitialData();
  }

  void _initializeDependencies() {
    _authRepo = locator.get<AuthRepository>();
    _feedbackRepo = locator.get<FeedbackRepository>();
  }

  // MARK: - Data Loading
  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await _loadFeedback();
    } catch (e) {
      _handleError('Failed to load trip history details', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadFeedback() async {
    try {
      final feedbackModel = await _feedbackRepo.getFeedbackByTravelId(
        _travelEntity.travelId.toString(),
      );

      if (mounted) {
        setState(() {
          _feedbackEntity =
              feedbackModel != null
                  ? FeedbackEntity(
                    feedbackId: feedbackModel.feedbackId,
                    travelId: feedbackModel.travelId,
                    rating: feedbackModel.rating,
                    feedback: feedbackModel.feedback,
                    createdAt: feedbackModel.createdAt,
                  )
                  : null;
        });
      }
    } catch (e) {
      debugPrint('Error loading feedback: $e');
      if (mounted) {
        setState(() => _feedbackEntity = null);
      }
    }
  }

  Future<void> _submitFeedback(double rating, String comments) async {
    if (_isSubmittingFeedback) return;

    setState(() => _isSubmittingFeedback = true);

    try {
      final user = await _authRepo.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _feedbackRepo.createFeedback(
        customerId: user.id,
        travelId: _travelEntity.travelId.toString(),
        rating: rating,
        feedback: comments,
      );

      await _loadFeedback();

      if (mounted) {
        _showSuccessMessage('Feedback submitted successfully');
      }
    } catch (e) {
      if (mounted) {
        _handleError('Failed to submit feedback', e);
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isSubmittingFeedback = false);
      }
    }
  }

  // MARK: - Error Handling & UI Feedback
  void _handleError(String message, dynamic error) {
    debugPrint('$message: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message. Please try again.'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoadingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // MARK: - UI Building
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Trip Details'),
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      centerTitle: true,
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading trip details...',
            style: TextStyle(fontSize: 16, color: AppTheme.secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildDocumentsSection(),
                    const SizedBox(height: 24),
                    _buildActionSection(),
                    if (_feedbackEntity != null) ...[
                      const SizedBox(height: 24),
                      _buildFeedbackDisplay(),
                    ],
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // MARK: - Document Section
  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Documents',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildDocumentGrid(),
        const SizedBox(height: 16),
        _buildOtherDocumentsButton(),
      ],
    );
  }

  Widget _buildDocumentGrid() {
    final documents = [
      DocumentSectionEntity(
        title: 'Hotels',
        icon: Icons.hotel,
        urls: _travelEntity.hotels ?? [],
      ),
      DocumentSectionEntity(
        title: 'Flights',
        icon: Icons.flight_rounded,
        urls: _travelEntity.flights ?? [],
      ),
      DocumentSectionEntity(
        title: 'Vehicles',
        icon: Icons.car_rental,
        urls: _travelEntity.vehicles ?? [],
      ),
      DocumentSectionEntity(
        title: 'Tour Itinerary',
        icon: Icons.tour_outlined,
        urls: _travelEntity.tourItineraries ?? [],
      ),
      DocumentSectionEntity(
        title: 'Transfers',
        icon: Icons.transfer_within_a_station,
        urls: _travelEntity.transfers ?? [],
      ),
      DocumentSectionEntity(
        title: 'Cruise Docs',
        icon: Icons.sailing,
        urls: _travelEntity.cruiseDocs ?? [],
      ),
      DocumentSectionEntity(
        title: 'Other Docs',
        icon: Icons.work_outline_sharp,
        urls: _travelEntity.otherCsaDocs ?? [],
      ),
    ];

    return Column(
      children:
          documents
              .where((doc) => doc.urls.isNotEmpty)
              .map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDocumentSection(doc),
                ),
              )
              .toList(),
    );
  }

  Widget _buildDocumentSection(DocumentSectionEntity section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(section.icon, color: AppTheme.whiteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${section.urls.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.whiteColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: section.urls.length,
            itemBuilder: (context, index) => _buildDocumentCard(section, index),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(DocumentSectionEntity section, int index) {
    return DocumentCard(
      title: '${section.title} ${index + 1}',
      onTap: () => _openDocument(section.urls[index], section.title, index),
    );
  }

  Widget _buildOtherDocumentsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openOtherDocuments(),
        icon: const Icon(Icons.folder_open),
        label: const Text('View My Documents'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // MARK: - Action Section
  Widget _buildActionSection() {
    if (_feedbackEntity != null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Feedback',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'How was your trip? Share your experience with us.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.whiteColor),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmittingFeedback ? null : _showFeedbackDialog,
            icon:
                _isSubmittingFeedback
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.star_rate),
            label: Text(
              _isSubmittingFeedback ? 'Submitting...' : 'Add Feedback',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - Feedback Display
  Widget _buildFeedbackDisplay() {
    final feedback = _feedbackEntity!;

    return FeedbackDisplayCard(
      feedback: feedback,
      onTap: () {
        // Handle tap
      },
    );
  }

  // MARK: - Dialogs
  void _showFeedbackDialog() {
    TripFeedbackDialog.show(
      context,
      onSubmit: (rating, comment) {
        _handleFeedbackSubmission(rating, comment);
      },
      onCancel: () {
        // Optional cancel callback
      },
    );
  }

  // MARK: - Navigation & Actions
  void _openDocument(String url, String title, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PdfViewerScreen(pdfUrl: url, title: '$title ${index + 1}'),
      ),
    );
  }

  void _openOtherDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => HistoryOtherDocumentsScreen(travel: _travelEntity),
      ),
    );
  }

  Future<void> _handleFeedbackSubmission(double rating, String comments) async {
    _showLoadingMessage('Submitting feedback...');

    try {
      await _submitFeedback(rating, comments);
    } catch (e) {
      // Error handling is done in _submitFeedback method
    }
  }
}
