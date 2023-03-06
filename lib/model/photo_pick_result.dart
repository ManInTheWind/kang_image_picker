import 'package:flutter/foundation.dart';

@immutable
class PhotoPickResult {
  final String path;
  final int width;
  final int height;
  final String? filename;
  final String? mimeType;

  const PhotoPickResult({
    required this.path,
    required this.width,
    required this.height,
    this.filename,
    this.mimeType,
  });

  @override
  String toString() {
    return 'PhotoPickResult{path: $path, width: $width, height: $height, filename: $filename, mimeType: $mimeType}';
  }
}
