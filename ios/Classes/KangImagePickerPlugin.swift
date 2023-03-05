import AVFoundation
import AVKit
import Flutter
import Photos
import UIKit
import YPImagePicker

public class KangImagePickerPlugin: NSObject, FlutterPlugin, YPImagePickerDelegate {
    public func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {}

//    private var FLUTTER_CANCEL_CODE: String = "-2"
//    private var FLUTTER_SELECTED_BUT_NOT_FOUND_CODE: String = "-2"

    private var selectedItems: [YPMediaItem]?

    public func noPhotos() {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }

    public func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "kang_image_picker", binaryMessenger: registrar.messenger())
        let instance = KangImagePickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "selectSinglePhoto":
            selectSinglePhoto(arguments: call.arguments, result)
        case "selectMultiPhotos":
            selectMultiPhotos(arguments: call.arguments, result)
        case "selectVideo":
            selectVideo(arguments: call.arguments, result)
        case "selectMultiVideo":
            selectMultiVideo(arguments: call.arguments, result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func selectSinglePhoto(arguments: Any?, _ result: @escaping FlutterResult) {
        var flutterPickConfiguration: FlutterPickerConfiguration
        if let arguments = arguments as? [String: Any?] {
            flutterPickConfiguration = FlutterPickerConfiguration(dict: arguments)
        } else {
            flutterPickConfiguration = FlutterPickerConfiguration()
        }

        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(FlutterError(code: "-1", message: "打开失败，获取FlutterViewController失败", details: nil))
            return
        }
        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = flutterPickConfiguration.mediaType
        config.library.itemOverlayType = .grid
        /* Adds a Filter step in the photo taking process. Defaults to true */
        /* 在拍照过程中添加滤镜步骤。默认为true */
        config.showsPhotoFilters = flutterPickConfiguration.showsPhotoFilters
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */
        config.shouldSaveNewPicturesToAlbum = true
        config.onlySquareImagesFromCamera = false

        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        /* 选择videoCompression。默认为AVAssetExportPresetHighestQuality */
//        config.video.compression = AVAssetExportPresetPassthrough

        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        /* 选择recordingSizeLimit。如果没有设置，则限制是时间。*/
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        let albumName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.albumName = albumName

        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */
        config.startOnScreen = flutterPickConfiguration.startOnScreen

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = flutterPickConfiguration.screens

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        if let cropRatio = flutterPickConfiguration.cropRatio {
            config.showsCrop = .rectangle(ratio: cropRatio)
        }

        /* 颜色 */
        if let tintColor = flutterPickConfiguration.tintColor {
            config.colors.tintColor = tintColor.uicolor()
        }

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = flutterPickConfiguration.maxNumberOfItems
        config.gallery.hidesRemoveButton = false

        /// 选择过的
        config.library.preselectedItems = selectedItems

        // Customise fonts
        // 自定义字体
        // config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        // config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        // config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        // config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        // config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        /* Customize wordings */
        /* 自定义字体 */
        config.wordings.cancel = "取消"
        config.wordings.next = "下一步"
        config.wordings.crop = "裁剪"
        config.wordings.save = "完成"
        config.wordings.libraryTitle = "图库"
        config.wordings.cameraTitle = "相机"

        let picker = YPImagePicker(configuration: config)

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            picker.navigationBar.scrollEdgeAppearance = navBarAppearance
        }

        picker.imagePickerDelegate = self

        /* Single Photo implementation. */
        picker.didFinishPicking { [weak picker] items, cancelled in

            if cancelled {
                print("Picker was canceled")
                result(self.getFlutterCancelError())
                picker?.dismiss(animated: true, completion: nil)
                return
            }

            _ = items.map { print("🧀 \($0)") }

            self.selectedItems = items

            guard let selectedPhoto = items.first else {
                result(self.getFlutterDefaultError(msg: "无法找到用户选择的图片"))
                return
            }

            switch selectedPhoto {
            case .photo(p: let photo):
                print("\(String(describing: photo.asset))")
                print("\(photo.fromCamera)")
                print("\(String(describing: photo.url))")
                print("\(String(describing: photo.exifMeta))")
                print("\(String(describing: photo.image))")
                if photo.fromCamera, photo.asset == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        let resultInAlbum = self.getPHAsset(inAlbumNamed: albumName)
                        if resultInAlbum == nil {
                            result(self.getFlutterDefaultError(msg: "无法找到用户选择的图片"))
                        } else {
                            resultInAlbum!.getURL(completionHandler: { (responseURL: URL?) in
                                if responseURL == nil {
                                    result(self.getFlutterDefaultError(msg: "无法找到用户选择的图片"))

                                } else {
                                    if #available(iOS 16.0, *) {
                                        result(responseURL!.path())
                                    } else {
                                        result(responseURL!.path)
                                    }
                                }

                            })
                        }
                    }

                } else if photo.asset == nil {
                    result(self.getFlutterDefaultError(msg: "无法找到用户选择的图片"))
                } else {
                    photo.asset!.getURL(completionHandler: { (responseURL: URL?) in
                        if responseURL == nil {
                            result(self.getFlutterDefaultError(msg: "无法找到用户选择的图片"))

                        } else {
                            if #available(iOS 16.0, *) {
                                result(responseURL!.path())
                            } else {
                                result(responseURL!.path)
                            }
                        }

                    })
                }
            case .video(v: _):
                result(nil)
            }

            picker?.dismiss(animated: true, completion: nil)
        }

        vc!.present(picker, animated: true, completion: nil)
    }

    func selectMultiPhotos(arguments: Any?, _ result: @escaping FlutterResult) {
        var flutterPickConfiguration: FlutterPickerConfiguration
        if let arguments = arguments as? [String: Any?] {
            flutterPickConfiguration = FlutterPickerConfiguration(dict: arguments)
        } else {
            flutterPickConfiguration = FlutterPickerConfiguration()
        }
        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(getFlutterDefaultError(msg: "打开失败，获取FlutterViewController失败"))
            return
        }

        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = flutterPickConfiguration.mediaType
        config.library.itemOverlayType = .grid
        /* Adds a Filter step in the photo taking process. Defaults to true */
        /* 在拍照过程中添加滤镜步骤。默认为true */
        config.showsPhotoFilters = flutterPickConfiguration.showsPhotoFilters
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */
        config.shouldSaveNewPicturesToAlbum = true

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        let albumName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.albumName = albumName

        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */
        config.startOnScreen = flutterPickConfiguration.startOnScreen

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = flutterPickConfiguration.screens

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        /* 是否开启裁剪，以及裁剪比例，默认.none */
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        if let cropRatio = flutterPickConfiguration.cropRatio {
            config.showsCrop = .rectangle(ratio: cropRatio)
        }

        /* 颜色 */
        if let tintColor = flutterPickConfiguration.tintColor {
            config.colors.tintColor = tintColor.uicolor()
        }

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = flutterPickConfiguration.maxNumberOfItems
        config.gallery.hidesRemoveButton = false

        /// 选择过的
        config.library.preselectedItems = selectedItems

        // Customise fonts
        // 自定义字体
        // config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        // config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        // config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        // config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        // config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        /* Customize wordings */
        /* 自定义字体 */
        config.wordings.cancel = "取消"
        config.wordings.next = "下一步"
        config.wordings.crop = "裁剪"
        config.wordings.save = "完成"
        config.wordings.libraryTitle = "图库"
        config.wordings.cameraTitle = "相机"

        let picker = YPImagePicker(configuration: config)

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            picker.navigationBar.scrollEdgeAppearance = navBarAppearance
        }

        picker.imagePickerDelegate = self

        /* Multiple media implementation */
        picker.didFinishPicking { [weak picker] items, cancelled in

            if cancelled {
                print("Picker was canceled")
                result(self.getFlutterCancelError())
                picker?.dismiss(animated: true, completion: nil)
                return
            }

            self.selectedItems = items

            var resultFilePathList = [String]()
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue.global()
            for item: YPMediaItem in items {
                dispatchGroup.enter()
                switch item {
                case .photo(p: let photo):
                    if photo.fromCamera, photo.asset == nil {
                        queue.asyncAfter(deadline: .now() + 0.8) {
                            if let photoInAlbum = self.getPHAsset(inAlbumNamed: albumName) {
                                photoInAlbum.getURL { responseURL in
                                    if let url = responseURL {
                                        if #available(iOS 16.0, *) {
                                            resultFilePathList.append(url.path())
                                        } else {
                                            resultFilePathList.append(url.path)
                                        }
                                    }
                                    dispatchGroup.leave()
                                }
                            } else {
                                dispatchGroup.leave()
                            }
                        }
                    } else if photo.asset == nil {
                        result(self.getFlutterSelectedButNotFoundError())
                        dispatchGroup.leave()
                    } else {
                        photo.asset!.getURL(completionHandler: { (responseURL: URL?) in
                            if responseURL == nil {
                                result(self.getFlutterSelectedButNotFoundError())
                            } else {
                                if #available(iOS 16.0, *) {
                                    resultFilePathList.append(responseURL!.path())
                                } else {
                                    resultFilePathList.append(responseURL!.path)
                                }
                            }
                            dispatchGroup.leave()
                        })
                    }

                case .video(v: let video):
                    let assetURL = video.url
                    if #available(iOS 16.0, *) {
                        resultFilePathList.append(assetURL.path())
                    } else {
                        resultFilePathList.append(assetURL.path)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                result(resultFilePathList)
                picker?.dismiss(animated: true)
            }
        }
        vc!.present(picker, animated: true, completion: nil)
    }

    func selectVideo(arguments: Any?, _ result: @escaping FlutterResult) {
        var flutterPickConfiguration: FlutterPickerConfiguration
        if let arguments = arguments as? [String: Any?] {
            flutterPickConfiguration = FlutterPickerConfiguration(dict: arguments)
        } else {
            flutterPickConfiguration = FlutterPickerConfiguration()
        }

        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(getFlutterDefaultError(msg: "打开失败，获取FlutterViewController失败"))
            return
        }

        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = flutterPickConfiguration.mediaType
        config.library.itemOverlayType = .grid
        config.showsPhotoFilters = flutterPickConfiguration.showsPhotoFilters
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */

        /* 选择videoCompression。默认为AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        // config.albumName = "ThisIsMyAlbum"
        config.albumName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.shouldSaveNewPicturesToAlbum = true

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */

        config.startOnScreen = flutterPickConfiguration.startOnScreen

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = flutterPickConfiguration.screens

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* 定义记录视频的时间限制。默认为30秒。 */
//        config.video.recordingTimeLimit = 20.0
//        config.video.trimmerMaxDuration = 20.0

        if let recordingTimeLimit = flutterPickConfiguration.videoRecordingTimeLimit {
            config.video.recordingTimeLimit = recordingTimeLimit
        }

        if let trimmerMaxDuration = flutterPickConfiguration.trimmerMaxDuration {
            config.video.trimmerMaxDuration = trimmerMaxDuration
        }

        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        /* 定义库中视频的时间限制。
         默认为60秒。 */
        config.video.libraryTimeLimit = 500.0

        /* Customize wordings */
        /* 自定义字体 */
        config.wordings.cancel = "取消"
        config.wordings.next = "下一步"
        config.wordings.crop = "裁剪"
        config.wordings.save = "完成"
        config.wordings.libraryTitle = "图库"
        config.wordings.cameraTitle = "相机"
        config.wordings.videoTitle = "视频"

        /* 颜色 */
        if let tintColor = flutterPickConfiguration.tintColor {
            config.colors.tintColor = tintColor.uicolor()
        }

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = flutterPickConfiguration.maxNumberOfItems

        config.gallery.hidesRemoveButton = false

//        config.library.preselectedItems = selectedItems

        let picker = YPImagePicker(configuration: config)

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            picker.navigationBar.scrollEdgeAppearance = navBarAppearance
        }

        picker.imagePickerDelegate = self

        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"

        /* Multiple media implementation */
        picker.didFinishPicking { [weak picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                result(self.getFlutterCancelError())
                picker?.dismiss(animated: true, completion: nil)
                return
            }
//            self.selectedItems = items
            guard let assetURL = items.singleVideo?.url else {
                result(self.getFlutterSelectedButNotFoundError())
                return
            }
            var videoResult: VideoPickResult
            var duration: Double
            var videoPath: String
            if let avAsset = AVAsset(url: assetURL) as AVAsset? {
                duration = avAsset.duration.seconds
            } else {
                duration = config.video.trimmerMaxDuration
            }
            if #available(iOS 16.0, *) {
                videoPath = assetURL.path()
            } else {
                videoPath = assetURL.path
            }
            videoResult = VideoPickResult(videoPath: videoPath, duration: duration)

            if let result = self.saveImage(items.singleVideo!.thumbnail) {
                videoResult.thumbnailPath = result.0
                videoResult.thumbnailWidth = result.1
                videoResult.thumbnailHeight = result.2
            }
            result(videoResult.toMap())

            picker?.dismiss(animated: true, completion: nil)
        }

        vc!.present(picker, animated: true, completion: nil)
    }

    func selectMultiVideo(arguments: Any?, _ result: @escaping FlutterResult) {
        var flutterPickConfiguration: FlutterPickerConfiguration
        if let arguments = arguments as? [String: Any?] {
            flutterPickConfiguration = FlutterPickerConfiguration(dict: arguments)
        } else {
            flutterPickConfiguration = FlutterPickerConfiguration()
        }

        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(getFlutterDefaultError(msg: "打开失败，获取FlutterViewController失败"))
            return
        }

        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = flutterPickConfiguration.mediaType
        config.library.itemOverlayType = .grid
        config.showsPhotoFilters = flutterPickConfiguration.showsPhotoFilters
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */

        /* 选择videoCompression。默认为AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        // config.albumName = "ThisIsMyAlbum"
        config.albumName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.shouldSaveNewPicturesToAlbum = true

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */

        config.startOnScreen = flutterPickConfiguration.startOnScreen

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = flutterPickConfiguration.screens

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* 定义记录视频的时间限制。默认为30秒。 */
//        config.video.recordingTimeLimit = 20.0
//        config.video.trimmerMaxDuration = 20.0

        if let recordingTimeLimit = flutterPickConfiguration.videoRecordingTimeLimit {
            config.video.recordingTimeLimit = recordingTimeLimit
        }

        if let trimmerMaxDuration = flutterPickConfiguration.trimmerMaxDuration {
            config.video.trimmerMaxDuration = trimmerMaxDuration
        }

        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        /* 定义库中视频的时间限制。
         默认为60秒。 */
        config.video.libraryTimeLimit = 500.0

        /* Customize wordings */
        /* 自定义字体 */
        config.wordings.cancel = "取消"
        config.wordings.next = "下一步"
        config.wordings.crop = "裁剪"
        config.wordings.save = "完成"
        config.wordings.libraryTitle = "图库"
        config.wordings.cameraTitle = "相机"
        config.wordings.videoTitle = "视频"

        /* 颜色 */
        if let tintColor = flutterPickConfiguration.tintColor {
            config.colors.tintColor = tintColor.uicolor()
        }

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = flutterPickConfiguration.maxNumberOfItems

        config.gallery.hidesRemoveButton = false

//        config.library.preselectedItems = selectedItems

        let picker = YPImagePicker(configuration: config)

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            picker.navigationBar.scrollEdgeAppearance = navBarAppearance
        }

        picker.imagePickerDelegate = self

        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"

        /* Multiple media implementation */
        picker.didFinishPicking { [weak picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                result(self.getFlutterCancelError())
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            var resultFilePathList = [[String: Any?]]()
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue.global(qos: .background)

            for item: YPMediaItem in items {
                dispatchGroup.enter()
                queue.async {
                    switch item {
                    case .photo(p: _):
                        dispatchGroup.leave()
                    case .video(v: let video):

                        let assetURL = video.url

                        var videoResult: VideoPickResult
                        var duration: Double
                        var videoPath: String
                        if let avAsset = AVAsset(url: assetURL) as AVAsset? {
                            duration = avAsset.duration.seconds
                        } else {
                            duration = config.video.trimmerMaxDuration
                        }
                        if #available(iOS 16.0, *) {
                            videoPath = assetURL.path()
                        } else {
                            videoPath = assetURL.path
                        }
                        videoResult = VideoPickResult(videoPath: videoPath, duration: duration)

                        if let result = self.saveImage(items.singleVideo!.thumbnail) {
                            videoResult.thumbnailPath = result.0
                            videoResult.thumbnailWidth = result.1
                            videoResult.thumbnailHeight = result.2
                        }
                        resultFilePathList.append(videoResult.toMap())
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                result(resultFilePathList)
                picker?.dismiss(animated: true)
            }
        }

        vc!.present(picker, animated: true, completion: nil)
    }

    func getPHAsset(inAlbumNamed albumName: String) -> PHAsset? {
        var resultAsset: PHAsset?
        // 查询所有系统相册
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)

        // 遍历所有相册，查找指定名称的相册
        var targetAlbum: PHAssetCollection?
        smartAlbums.enumerateObjects { album, _, _ in
            if album.localizedTitle == albumName {
                targetAlbum = album
            }
        }
        if targetAlbum == nil {
            userAlbums.enumerateObjects { album, _, _ in
                if album.localizedTitle == albumName {
                    targetAlbum = album
                }
            }
        }

        if let targetAlbum = targetAlbum {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            /// 查询
            let result = PHAsset.fetchAssets(in: targetAlbum, options: fetchOptions)
            if let asset = result.firstObject {
                resultAsset = asset
                print("查询到的最新照片PHAsset对象为：\(String(describing: resultAsset))")

            } else {
                print("查询到的最新照片PHAsset对象为：\(String(describing: resultAsset))")
            }
        }

        return resultAsset
    }

    func saveImage(_ image: UIImage) -> (String, Int, Int)? {
        // 获取当前时间作为文件名
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMddHHmmssSSS"
//        let filename = formatter.string(from: date)

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let randomNum = Int(arc4random_uniform(UInt32.max))
        let filename = "thumbnail_\(timestamp)_\(randomNum)"

        // 获取Documents目录路径
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

        // 拼接文件路径
        let filePath = "\(documentsPath)/\(filename).jpg"

        // 保存图片
        do {
            try image.jpegData(compressionQuality: 0.8)?.write(to: URL(fileURLWithPath: filePath))
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }

        // 获取图片宽度和高度
        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height

        // 返回路径、宽度和高度信息
        return (filePath, Int(round(width)), Int(round(height)))
    }

    func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getCurrentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        return base
    }

    func getFlutterDefaultError(msg: String? = "操作失败") -> FlutterError {
        return FlutterError(code: "-1", message: msg, details: nil)
    }

    func getFlutterCancelError() -> FlutterError {
        return FlutterError(code: "-2", message: "用户取消选择", details: nil)
    }

    func getFlutterSelectedButNotFoundError() -> FlutterError {
        return FlutterError(code: "-3", message: "找不到用户选择的资源", details: nil)
    }
}

extension PHAsset {
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }

    func getURL(completionHandler: @escaping ((_ responseURL: URL?) -> Void)) {
        if mediaType == .image {
            let options: PHContentEditingInputRequestOptions = .init()
            options.canHandleAdjustmentData = { (_: PHAdjustmentData) -> Bool in
                true
            }
            requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, _: [AnyHashable: Any]) in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if mediaType == .video {
            let options: PHVideoRequestOptions = .init()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: { (asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable: Any]?) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension String {
    /// 十六进制字符串颜色转为UIColor
    /// - Parameter alpha: 透明度
    func uicolor(alpha: CGFloat = 1.0) -> UIColor {
        // 存储转换后的数值
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        var hex = self
        // 如果传入的十六进制颜色有前缀，去掉前缀
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理，当然你也可以进行其它操作
        if hex.count < 6 {
            for _ in 0..<6 - hex.count {
                hex += "0"
            }
        }

        // 分别进行转换
        // 红
        Scanner(string: String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        // 绿
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        // 蓝
        Scanner(string: String(hex[hex.index(startIndex, offsetBy: 4)...])).scanHexInt64(&blue)

        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
