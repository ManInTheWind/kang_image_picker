import 'package:flutter/services.dart';

class KangImagePicker {
  static const _methodChannel = MethodChannel('kang_image_picker');

  static Future<String?> getPlatformVersion() async {
    return await _methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  static Future<bool?> openPicker() async {
    return await _methodChannel.invokeMethod<bool>('openPicker');
  }
}
