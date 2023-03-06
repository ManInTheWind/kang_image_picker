import 'package:flutter/foundation.dart';

@immutable
class VideoPickResult {
  final String videoPath;
  final String thumbnailPath;
  final int thumbnailWidth;
  final int thumbnailHeight;
  final double duration;

  const VideoPickResult({
    required this.videoPath,
    required this.thumbnailPath,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.duration,
  });

  @override
  String toString() {
    return 'VideoPickResult{videoPath: $videoPath, thumbnailPath: $thumbnailPath, thumbnailWidth: $thumbnailWidth, thumbnailHeight: $thumbnailHeight, duration: $duration}';
  }
}
