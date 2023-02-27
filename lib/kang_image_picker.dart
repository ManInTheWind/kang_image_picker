import 'package:flutter/services.dart';
import 'package:kang_image_picker/model/video_selected_result.dart';

class KangImagePicker {
  static const _methodChannel = MethodChannel('kang_image_picker');

  static Future<String?> getPlatformVersion() async {
    return await _methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  ///返回文件路径
  static Future<String?> selectSinglePhoto() async {
    return await _methodChannel.invokeMethod<String?>('selectSinglePhoto');
  }

  static Future<List<String>?> selectMultiPhotos() async {
    final res =
        await _methodChannel.invokeMethod<List<Object?>>('selectMultiPhotos');
    return res?.map((e) => e as String).toList();
  }

  static Future<VideoSelectedResult?> selectVideo() async {
    final result = await _methodChannel.invokeMethod<Object?>('selectVideo');
    VideoSelectedResult? videoSelectedResult;
    if (result != null && result is Map) {
      videoSelectedResult = VideoSelectedResult(
        videoPath: result['videoPath'] as String,
        thumbnailPath: result['thumbnailPath'] as String?,
        thumbnailWidth: result['thumbnailWidth'] as double?,
        thumbnailHeight: result['thumbnailHeight'] as double?,
        duration: result['duration'] as double,
      );
    }
    return videoSelectedResult;
  }
}
