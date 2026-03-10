import 'package:flutter/material.dart';

class UploadSection extends StatelessWidget {
  final String title;
  final String? selectedDocumentType;
  final Map<String, List<dynamic>> documents;
  final ValueChanged<String?> onDocumentTypeChanged;
  final VoidCallback onUploadPressed;
  final bool isUploading;
  final String supportedFormatsText;
  final int maxFilesPerCategory;
  final String dropdownLabel;
  final String uploadButtonText;
  final String uploadingButtonText;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? titleColor;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final IconData dropdownIcon;
  final IconData uploadIcon;

  const UploadSection({
    super.key,
    required this.documents,
    required this.onDocumentTypeChanged,
    required this.onUploadPressed,
    this.title = 'Upload Documents',
    this.selectedDocumentType,
    this.isUploading = false,
    this.supportedFormatsText = 'Supported formats: PDF, JPG, PNG, DOC, DOCX',
    this.maxFilesPerCategory = 5,
    this.dropdownLabel = 'Select Document Type',
    this.uploadButtonText = 'Upload Files',
    this.uploadingButtonText = 'Uploading...',
    this.backgroundColor,
    this.borderColor,
    this.titleColor,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 12,
    this.dropdownIcon = Icons.folder_outlined,
    this.uploadIcon = Icons.cloud_upload_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: titleColor ?? primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdown(context),
          const SizedBox(height: 16),
          _buildUploadButton(context),
          const SizedBox(height: 8),
          _buildSupportedFormatsText(context),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedDocumentType,
      decoration: InputDecoration(
        labelText: dropdownLabel,
        prefixIcon: Icon(dropdownIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          documents.keys.map((String type) {
            final files = documents[type] ?? [];
            final count = files.length;
            return DropdownMenuItem<String>(
              value: type,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(type, overflow: TextOverflow.ellipsis)),
                  Text(
                    '($count/$maxFilesPerCategory)',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          count >= maxFilesPerCategory
                              ? Colors.red
                              : Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      onChanged: onDocumentTypeChanged,
      isExpanded: true,
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isUploading ? null : onUploadPressed,
      icon:
          isUploading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Icon(uploadIcon),
      label: Text(isUploading ? uploadingButtonText : uploadButtonText),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSupportedFormatsText(BuildContext context) {
    final fullText =
        '$supportedFormatsText (Max $maxFilesPerCategory files per category)';

    return Text(
      fullText,
      style: TextStyle(fontSize: 12, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }
}
