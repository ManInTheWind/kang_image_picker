import 'package:flutter/foundation.dart';

@immutable
class VideoPickResult {
  final String videoPath;
  final String videoFilename;
  final String thumbnailPath;
  final String thumbnailFilename;
  final int thumbnailWidth;
  final int thumbnailHeight;
  final double duration;

  // const VideoPickResult({
  //   required this.videoPath,
  //   required this.thumbnailPath,
  //   required this.thumbnailWidth,
  //   required this.thumbnailHeight,
  //   required this.duration,
  // });

  VideoPickResult.fromJson(Map json)
      : videoPath = json['videoPath'] as String,
        videoFilename = json['videoFilename'] as String,
        thumbnailPath = json['thumbnailPath'] as String,
        thumbnailFilename = json['thumbnailFilename'] as String,
        thumbnailWidth = json['thumbnailWidth'] as int,
        thumbnailHeight = json['thumbnailHeight'] as int,
        duration = json['duration'] as double;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'videoPath': videoPath,
        'videoFilename': videoFilename,
        'thumbnailPath': thumbnailPath,
        'thumbnailFilename': thumbnailFilename,
        'thumbnailWidth': thumbnailWidth,
        'thumbnailHeight': thumbnailHeight,
        'duration': duration,
      };

  @override
  String toString() {
    return 'VideoPickResult{videoPath: $videoPath,videoFilename:$videoFilename, thumbnailPath: $thumbnailPath,thumbnailFilename: $thumbnailFilename, thumbnailWidth: $thumbnailWidth, thumbnailHeight: $thumbnailHeight, duration: $duration}';
  }
}
