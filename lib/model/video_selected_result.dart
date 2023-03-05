import 'package:flutter/foundation.dart';

@immutable
class VideoSelectedResult {
  final String videoPath;
  final String? thumbnailPath;
  final int? thumbnailWidth;
  final int? thumbnailHeight;
  final double duration;

  const VideoSelectedResult({
    required this.videoPath,
    this.thumbnailPath,
    this.thumbnailWidth,
    this.thumbnailHeight,
    required this.duration,
  });

  @override
  String toString() {
    return 'VideoSelectedResult{videoPath: $videoPath, thumbnailPath: $thumbnailPath, thumbnailWidth: $thumbnailWidth, thumbnailHeight: $thumbnailHeight, duration: $duration}';
  }
}
