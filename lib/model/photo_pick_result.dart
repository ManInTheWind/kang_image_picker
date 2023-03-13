// import 'package:flutter/foundation.dart';
part of kang_image_picker;

@immutable
class PhotoPickResult {
  /// iOS:PHAssets.localIdentifier
  /// Android: file Id
  final String id;
  final String path;
  final int width;
  final int height;
  final String filename;
  final String? mimeType;

  const PhotoPickResult({
    required this.id,
    required this.path,
    required this.width,
    required this.height,
    required this.filename,
    this.mimeType,
  });

  @override
  String toString() {
    return 'PhotoPickResult{id: $id,path: $path, width: $width, height: $height, filename: $filename, mimeType: $mimeType}';
  }
}
