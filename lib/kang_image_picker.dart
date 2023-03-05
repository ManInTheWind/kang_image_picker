import 'package:flutter/services.dart';
import 'package:kang_image_picker/model/picker_configuration.dart';
import 'package:kang_image_picker/model/video_selected_result.dart';

class KangImagePicker {
  static const _methodChannel = MethodChannel('kang_image_picker');

  static Future<String?> getPlatformVersion() async {
    return await _methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  ///返回文件路径
  static Future<String?> selectSinglePhoto({
    PickerConfiguration configuration = const PickerConfiguration(),
  }) async {
    return await _methodChannel.invokeMethod<String?>(
      'selectSinglePhoto',
      configuration.toJson(),
    );
  }

  static Future<List<String>?> selectMultiPhotos({
    PickerConfiguration configuration = const PickerConfiguration(),
  }) async {
    final res = await _methodChannel.invokeMethod<List<Object?>>(
      'selectMultiPhotos',
      configuration.toJson(),
    );
    if (res == null || res.isEmpty) {
      return null;
    }
    List<String> paths = <String>[];
    for (var path in res) {
      if (path == null) {
        continue;
      }
      paths.add(path as String);
    }
    return paths;
  }

  static Future<VideoSelectedResult?> selectVideo({
    PickerConfiguration configuration = const PickerConfiguration(),
  }) async {
    final result = await _methodChannel.invokeMethod<Object?>(
      'selectVideo',
      configuration.toJson(),
    );
    VideoSelectedResult? videoSelectedResult;
    if (result != null && result is Map) {
      videoSelectedResult = VideoSelectedResult(
        videoPath: result['videoPath'] as String,
        thumbnailPath: result['thumbnailPath'] as String?,
        thumbnailWidth: result['thumbnailWidth'] as int?,
        thumbnailHeight: result['thumbnailHeight'] as int?,
        duration: result['duration'] as double,
      );
    }
    return videoSelectedResult;
  }

  static Future<List<VideoSelectedResult>?> selectMultiVideo({
    PickerConfiguration configuration = const PickerConfiguration(),
  }) async {
    final result = await _methodChannel.invokeMethod<Object?>(
      'selectMultiVideo',
      configuration.toJson(),
    );
    if (result == null) {
      return null;
    }
    List<VideoSelectedResult> videoSelectedList = <VideoSelectedResult>[];
    if (result is List) {
      for (var resultItem in result) {
        if (resultItem != null && resultItem is Map) {
          VideoSelectedResult videoSelectedResult = VideoSelectedResult(
            videoPath: resultItem['videoPath'] as String,
            thumbnailPath: resultItem['thumbnailPath'] as String?,
            thumbnailWidth: resultItem['thumbnailWidth'] as int?,
            thumbnailHeight: resultItem['thumbnailHeight'] as int?,
            duration: resultItem['duration'] as double,
          );
          videoSelectedList.add(videoSelectedResult);
        }
      }
    }
    return videoSelectedList;
  }
}
