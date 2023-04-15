part of kang_image_picker;

@immutable
class VideoPickResult {
  final String videoPath;
  final String videoFilename;
  final String thumbnailPath;
  final String thumbnailFilename;
  final int thumbnailWidth;
  final int thumbnailHeight;
  final double duration;
  final int size;

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
        duration = json['duration'] as double,
        size = json['size'] as int;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'videoPath': videoPath,
        'videoFilename': videoFilename,
        'thumbnailPath': thumbnailPath,
        'thumbnailFilename': thumbnailFilename,
        'thumbnailWidth': thumbnailWidth,
        'thumbnailHeight': thumbnailHeight,
        'duration': duration,
        'size': size,
      };

  @override
  String toString() {
    return 'VideoPickResult{videoPath: $videoPath,videoFilename:$videoFilename, thumbnailPath: $thumbnailPath,thumbnailFilename: $thumbnailFilename, thumbnailWidth: $thumbnailWidth, thumbnailHeight: $thumbnailHeight, duration: $duration}';
  }
}
