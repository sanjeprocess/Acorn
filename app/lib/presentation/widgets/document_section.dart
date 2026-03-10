import 'package:arcon_travel_app/core/theme.dart';
import 'package:arcon_travel_app/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';
import '../../data/models/document_file_model.dart';

class DocumentSectionWidget extends StatelessWidget {
  final String title;
  final List<DocumentFileModel> files;
  final int maxFiles;
  final Widget Function(DocumentFileModel file, String sectionTitle)?
  fileCardBuilder;
  final VoidCallback? onAddPressed;
  final String emptyStateText;
  final IconData emptyStateIcon;
  final Color? titleColor;
  final Color? countBackgroundColor;
  final Color? countTextColor;
  final Color? emptyStateBackgroundColor;
  final Color? emptyStateBorderColor;
  final Color? emptyStateIconColor;
  final Color? emptyStateTextColor;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double listHeight;
  final bool showAddButton;
  final String addButtonText;
  final IconData addButtonIcon;

  const DocumentSectionWidget({
    super.key,
    required this.title,
    required this.files,
    this.maxFiles = 5,
    this.fileCardBuilder,
    this.onAddPressed,
    this.emptyStateText = 'No documents uploaded',
    this.emptyStateIcon = Icons.description_outlined,
    this.titleColor,
    this.countBackgroundColor,
    this.countTextColor,
    this.emptyStateBackgroundColor,
    this.emptyStateBorderColor,
    this.emptyStateIconColor,
    this.emptyStateTextColor,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 8,
    this.listHeight = 80,
    this.showAddButton = false,
    this.addButtonText = 'Add Document',
    this.addButtonIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    final isAtLimit = files.length >= maxFiles;

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (files.isNotEmpty) _buildHeader(context, isAtLimit),
          const SizedBox(height: 12),
          if (files.isNotEmpty) _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAtLimit) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: titleColor ?? Colors.white,
            ),
          ),
        ),
        if (showAddButton && !isAtLimit) ...[
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onAddPressed,
            icon: Icon(addButtonIcon, size: 16),
            label: Text(addButtonText),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
        const SizedBox(width: 8),
        _buildCountBadge(isAtLimit),
      ],
    );
  }

  Widget _buildCountBadge(bool isAtLimit) {
    final backgroundColor =
        isAtLimit
            ? (countBackgroundColor ?? Colors.red.withOpacity(0.1))
            : (countBackgroundColor ?? AppTheme.whiteColor.withOpacity(0.1));

    final textColor =
        isAtLimit
            ? (countTextColor ?? Colors.red)
            : (countTextColor ?? AppTheme.whiteColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${files.length}/$maxFiles',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (files.isEmpty) {
      return SizedBox();
    }

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          if (fileCardBuilder != null) {
            return fileCardBuilder!(files[index], title);
          }
          return _buildDefaultFileCard(files[index], context);
        },
      ),
    );
  }

  Widget _buildDefaultFileCard(DocumentFileModel file, BuildContext context) {
    final ext = file.extension.toLowerCase();
    final isImage = ext == 'jpg' || ext == 'jpeg' || ext == 'png';
    final isPdf = ext == 'pdf';
    final isWord = ext == 'doc' || ext == 'docx';

    IconData icon = Icons.insert_drive_file_outlined;
    String subtitle = 'Tap to view';
    if (isImage) {
      icon = Icons.image_outlined;
      subtitle = 'Tap to view image';
    } else if (isPdf) {
      icon = Icons.picture_as_pdf;
      subtitle = 'Tap to view PDF';
    } else if (isWord) {
      icon = Icons.description_outlined;
      subtitle = 'Tap to view document';
    }

    return DocumentCard(
      title: file.name,
      subtitle: subtitle,
      icon: icon,
      onTap: file.onTap ?? () => {},
      onLongPress: file.longTap ?? () => {},
    );
  }
}
