//
//  PickerConfiguration.swift
//  kang_image_picker
//
//  Created by kangkang on 2023/2/28.
//

import Foundation
import YPImagePicker

struct VideoPickResult {
    var videoPath: String
    var duration: Double
    var thumbnailPath: String?
    var thumbnailWidth: Int?
    var thumbnailHeight: Int?

    func toMap() -> [String: Any?] {
        var map = [String: Any?]()
        map["videoPath"] = videoPath
        map["duration"] = duration
        map["thumbnailPath"] = thumbnailPath
        map["thumbnailWidth"] = thumbnailWidth
        map["thumbnailHeight"] = thumbnailHeight
        return map
    }
}

class FlutterPickerConfiguration: CustomStringConvertible {
    /// 选择库中可用的媒体类型。默认为.photo
    var mediaType: YPlibraryMediaType

    /// 在拍照过程中添加滤镜步骤。默认为true
    var showsPhotoFilters: Bool

    /// 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo`
    var startOnScreen: YPPickerScreen

    /// 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]`
    var screens: [YPPickerScreen]

    /// 是否开启裁剪，以及裁剪比例，默认.none
    var cropRatio: Double?

    /// 主题颜色
    var tintColor: String?

    var maxNumberOfItems: Int

    /// 定义记录视频的时间限制。默认为30秒
    var videoRecordingTimeLimit: Double?

    /// 视频长度。默认60秒
    var trimmerMaxDuration: Double?

    init(dict: [String: Any?]) {
        if let mediaTypeFromFlutter = dict["mediaType"] as? Int {
            switch mediaTypeFromFlutter {
            case 0:
                mediaType = YPlibraryMediaType.photo
            case 1:
                mediaType = YPlibraryMediaType.video
            case 2:
                mediaType = YPlibraryMediaType.photoAndVideo
            default:
                mediaType = YPlibraryMediaType.photoAndVideo
            }
        } else {
            mediaType = YPlibraryMediaType.photoAndVideo
        }
        showsPhotoFilters = dict["showsPhotoFilters"] as? Bool ?? true
        if let startOnScreenFromFlutter = dict["startOnScreen"] as? Int {
            switch startOnScreenFromFlutter {
            case 0:
                startOnScreen = YPPickerScreen.library
            case 1:
                startOnScreen = YPPickerScreen.photo
            case 2:
                startOnScreen = YPPickerScreen.video
            default:
                startOnScreen = YPPickerScreen.library
            }
        } else {
            startOnScreen = YPPickerScreen.library
        }
        screens = [YPPickerScreen]()
        if let screensFromFlutter = dict["screens"] as? [Int] {
            for items in screensFromFlutter {
                switch items {
                case 0:
                    screens.append(YPPickerScreen.library)
                case 1:
                    screens.append(YPPickerScreen.photo)
                case 2:
                    screens.append(YPPickerScreen.video)
                default:
                    screens.append(YPPickerScreen.library)
                }
            }
        } else {
            screens = [.library, .photo]
        }
        cropRatio = dict["cropRatio"] as? Double
        tintColor = dict["tintColor"] as? String
        maxNumberOfItems = dict["maxNumberOfItems"] as? Int ?? 1
        videoRecordingTimeLimit = dict["videoRecordingTimeLimit"] as? Double
        trimmerMaxDuration = dict["trimmerMaxDuration"] as? Double
    }

    init() {
        mediaType = .photo
        showsPhotoFilters = false
        startOnScreen = .library
        screens = [.library, .photo]
        cropRatio = nil
        tintColor = nil
        maxNumberOfItems = 1
        videoRecordingTimeLimit = nil
        trimmerMaxDuration = nil
    }

    var description: String {
        return """
        FlutterPickerConfiguration {
            mediaType: \(String(describing: mediaType))
            showsPhotoFilters: \(showsPhotoFilters)
            startOnScreen: \(String(describing: startOnScreen))
            screens: \(screens.map { String(describing: $0) })
            cropRatio: \(cropRatio as Any)
            tintColor: \(tintColor as Any)
            maxNumberOfItems: \(maxNumberOfItems)
        }
        """
    }
}
