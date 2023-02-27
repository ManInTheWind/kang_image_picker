import 'package:flutter/services.dart';

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

  static Future<String?> selectVideo() async {
    return await _methodChannel.invokeMethod<String?>('selectVideo');
  }
}
