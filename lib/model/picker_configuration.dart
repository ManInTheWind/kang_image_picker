part of kang_image_picker;

enum PickerMediaType { photo, video, photoAndVideo }

enum PickerScreenEnum {
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

  ///在拍照过程中添加滤镜步骤。默认为false,Android不生效
  final bool showsPhotoFilters;

  ///定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` Android不生效
  final PickerScreenEnum startOnScreen;

  ///定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]`
  final List<PickerScreenEnum> screens;

  ///是否开启裁剪，以及裁剪比例，默认.none 只有单选生效
  final double? cropRatio;

  ///主题颜色
  final String? tintColor;

  ///选择数量
  final int maxNumberOfItems;

  ///定义记录视频的时间限制。默认为30秒
  final int? videoRecordingTimeLimit;

  ///视频长度。默认60秒
  final int? trimmerMaxDuration;

  const PickerConfiguration({
    this.mediaType = PickerMediaType.photo,
    this.showsPhotoFilters = false,
    this.startOnScreen = PickerScreenEnum.library,
    this.screens = const <PickerScreenEnum>[
      PickerScreenEnum.library,
      PickerScreenEnum.photo
    ],
    this.cropRatio,
    this.tintColor = "#2BD180",
    this.maxNumberOfItems = 1,
    this.videoRecordingTimeLimit,
    this.trimmerMaxDuration,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mediaType': mediaType.index,
        'showsPhotoFilters': showsPhotoFilters,
        'startOnScreen': startOnScreen.index,
        'screens': screens.map((e) => e.index).toList(),
        'cropRatio': cropRatio,
        'tintColor': tintColor,
        'maxNumberOfItems': maxNumberOfItems,
        'videoRecordingTimeLimit': videoRecordingTimeLimit,
        'trimmerMaxDuration': trimmerMaxDuration,
      }..removeWhere((key, value) => value == null);
}
