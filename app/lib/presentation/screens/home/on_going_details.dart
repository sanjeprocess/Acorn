import 'package:arcon_travel_app/data/repositories/travels_repository.dart';
import 'package:arcon_travel_app/presentation/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../domain/entities/document_section_entity.dart';
import '../../../domain/entities/travel_entity.dart';
import '../../widgets/document_card.dart';
import '../../widgets/pdf_view_widget.dart';
import 'other_document_page.dart';

class OnGoingDetails extends StatefulWidget {
  final TravelEntity travelEntity;

  const OnGoingDetails({super.key, required this.travelEntity});

  @override
  State<OnGoingDetails> createState() => _OnGoingDetailsState();
}

class _OnGoingDetailsState extends State<OnGoingDetails> {
  // State variables
  late TravelEntity _travelEntity;
  final _travelRepo = locator<TravelsRepository>();
  bool _isUpdating = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _travelEntity = widget.travelEntity;
  }

  // Mark : - UI Building
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(appBar: _buildAppBar(), body: _buildContent());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Trip Details'),
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      centerTitle: true,
      actions: [
        _isUpdating
            ? Container(
              margin: const EdgeInsets.all(12),
              width: 24,
              height: 24,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.whiteColor),
              ),
            )
            : IconButton(
              icon: const Icon(Icons.done_outline_rounded),
              onPressed: _handleMarkComplete,
            ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const SizedBox(height: 16), _buildDocumentsSection()],
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
        onPressed: _isUpdating ? null : () => _openOtherDocuments(),
        icon: const Icon(Icons.folder_open),
        label: const Text('View My Documents'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // MARK: - Actions
  Future<void> _handleMarkComplete() async {
    // Show confirmation dialog first
    final bool? confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _travelRepo.updateTravelToComplete(_travelEntity.travelId);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Trip marked as complete successfully!',
              style: TextStyle(color: AppTheme.whiteColor),
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back with result to trigger refresh
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (error) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update trip: ${error.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark Trip as Complete'),
          content: const Text(
            'Are you sure you want to mark this trip as complete? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Mark Complete'),
            ),
          ],
        );
      },
    );
  }

  // MARK: - Navigation
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
        builder: (context) => OtherDocumentsScreen(travel: _travelEntity),
      ),
    );
  }
}
