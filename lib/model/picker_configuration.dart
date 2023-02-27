enum PickerMediaType { photo, video, photoAndVideo }

enum PickerScreen {
  ///相册
  library,

  ///相机
  photo,

  ///录制
  video,
}

class PickerConfiguration {
  ///选择库中可用的媒体类型。默认为.photo
  final PickerMediaType mediaType;

  ///在拍照过程中添加滤镜步骤。默认为true
  final bool showsPhotoFilters;

  ///定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo`
  final PickerScreen startOnScreen;

  ///定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]`
  final List<PickerScreen> screens;

  ///是否开启裁剪，以及裁剪比例，默认.none
  final double? cropRatio;

  ///主题颜色
  final String? tintColor;

  const PickerConfiguration({
    this.mediaType = PickerMediaType.photo,
    this.showsPhotoFilters = false,
    this.startOnScreen = PickerScreen.library,
    this.screens = const <PickerScreen>[
      PickerScreen.library,
      PickerScreen.photo
    ],
    this.cropRatio,
    this.tintColor,
  });
}
