class DocumentFileModel {
  final String name;
  final String path;
  final int size;
  final String extension;
  final DateTime uploadTime;
  final String url;
  Function()? onTap;
  Function()? longTap;

  DocumentFileModel({
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    required this.uploadTime,
    required this.url,
    this.onTap,
    this.longTap,
  });

  /// Create DocumentFile from JSON
  factory DocumentFileModel.fromJson(Map<String, dynamic> json) {
    return DocumentFileModel(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      extension: json['extension'] ?? '',
      uploadTime: DateTime.parse(
        json['uploadTime'] ?? DateTime.now().toIso8601String(),
      ),
      url: json['url'] ?? '',
    );
  }

  /// Convert DocumentFile to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'extension': extension,
      'uploadTime': uploadTime.toIso8601String(),
      'url': url,
    };
  }

  /// Check if the document is a PDF
  bool get isPdf => extension.toLowerCase() == 'pdf';

  /// Get formatted file size
  String get formattedSize {
    if (size == 0) return 'Unknown size';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get formatted upload time
  String get formattedUploadTime {
    final now = DateTime.now();
    final difference = now.difference(uploadTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  /// Copy with new values
  DocumentFileModel copyWith({
    String? name,
    String? path,
    int? size,
    String? extension,
    DateTime? uploadTime,
    String? url,
    Function()? onTap,
    Function()? longTap,
  }) {
    return DocumentFileModel(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      extension: extension ?? this.extension,
      uploadTime: uploadTime ?? this.uploadTime,
      url: url ?? this.url,
      onTap: onTap ?? this.onTap,
      longTap: longTap ?? this.longTap,
    );
  }

  @override
  String toString() {
    return 'DocumentFile(name: $name, extension: $extension, size: $size, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentFileModel && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
