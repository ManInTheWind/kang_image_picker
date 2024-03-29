library kang_image_picker;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'model/photo_pick_result.dart';
part 'model/picker_configuration.dart';
part 'model/video_pick_result.dart';

class KangImagePicker {
  static const _methodChannel = MethodChannel('kang_image_picker');

  static Future<String?> getPlatformVersion() async {
    return await _methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  static Future<List<PhotoPickResult>?> selectPhotos({
    PickerConfiguration configuration = const PickerConfiguration(),
  }) async {
    final pickResultList = await _methodChannel.invokeMethod<List<Object?>>(
      'selectPhotos',
      configuration.toJson(),
    );
    if (pickResultList == null) {
      return null;
    }
    List<PhotoPickResult> photoPickResultList = <PhotoPickResult>[];

    for (Object? result in pickResultList) {
      if (result != null && result is Map) {
        final photoPickResult = PhotoPickResult(
          id: result['id'] as String,
          path: result['path'] as String,
          width: result['width'] as int,
          height: result['height'] as int,
          filename: result['filename'] as String,
          mimeType: result['mimeType'] as String?,
          size: result['size'] as int,
        );
        photoPickResultList.add(photoPickResult);
      }
    }
    return photoPickResultList;
  }

  static Future<List<VideoPickResult>?> selectVideos({
    PickerConfiguration configuration = const PickerConfiguration(),
  }) async {
    // print('selectVideos:${configuration.toJson()}');
    final result = await _methodChannel.invokeMethod<Object?>(
      'selectVideos',
      configuration.toJson(),
    );
    if (result == null) {
      return null;
    }
    List<VideoPickResult> videoSelectedList = <VideoPickResult>[];
    if (result is List) {
      for (var resultItem in result) {
        if (resultItem != null && resultItem is Map) {
          VideoPickResult videoSelectedResult =
              VideoPickResult.fromJson(resultItem);
          videoSelectedList.add(videoSelectedResult);
        }
      }
    }
    return videoSelectedList;
  }
}
