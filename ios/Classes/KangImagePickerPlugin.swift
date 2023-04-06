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
        case "selectPhotos":
            selectPhotos(arguments: call.arguments, result)
        case "selectVideos":
            selectVideos(arguments: call.arguments, result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func selectPhotos(arguments: Any?, _ result: @escaping FlutterResult) {
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
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.albumName = bundleName

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
        config.wordings.processing = "正在处理中"
        config.wordings.warningMaxItemsLimit = "所选照片超过最大可选数量"
        config.wordings.albumsTitle = "相簿"
        config.wordings.libraryTitle = "图库"
        config.wordings.cameraTitle = "相机"
        config.wordings.videoTitle = "视频"
        config.wordings.trim = "裁剪"
        config.wordings.cover = "封面"
        config.wordings.filter = "滤镜"
        config.wordings.videoDurationPopup.title = "提示"
        config.wordings.videoDurationPopup.tooShortMessage = "录制时间过短"
        config.wordings.videoDurationPopup.tooLongMessage = "录制时间过长"
        config.wordings.permissionPopup.title = "提示"
        config.wordings.permissionPopup.message = "\(bundleName)想要访问您的媒体资源权限以用作发表推文,更新头像等操作"
        config.wordings.permissionPopup.cancel = "取消"
        config.wordings.permissionPopup.grantPermission = "允许"

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
                result(nil)
                self.selectedItems = nil
                picker?.dismiss(animated: true, completion: nil)
                return
            }

            self.selectedItems = items

            var pickResultList = [[String: Any?]]()
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue.global()
            for item: YPMediaItem in items {
                dispatchGroup.enter()
                switch item {
                case .photo(p: let photo):
                    if photo.fromCamera, photo.asset == nil {
                        let activityIndicator = UIActivityIndicatorView()
                        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.midX,
                                                           y: UIScreen.main.bounds.midY)
                       
                        if #available(iOS 13.0, *) {
                            activityIndicator.color = .gray
                            activityIndicator.style = UIActivityIndicatorView.Style.large
                        } else {
                            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        }

                        picker?.view.addSubview(activityIndicator)

                        activityIndicator.startAnimating()

                        queue.asyncAfter(deadline: .now() + 0.8) {
                            if let photoInAlbum = self.getPHAsset(inAlbumNamed: bundleName) {
                                photoInAlbum.getURL { responseURL in
                                    if let url = responseURL {
                                        var photoPath: String
                                        if #available(iOS 16.0, *) {
                                            photoPath = url.path()
                                        } else {
                                            photoPath = url.path
                                        }
                                        var photoFilename: String

                                        if let filename = photo.asset?.originalFilename {
                                            photoFilename = filename

                                        } else {
                                            photoFilename = url.lastPathComponent
                                        }

                                        let pickResult = PhotoPickResult(
                                            id: photo.asset?.localIdentifier ?? UUID().uuidString,
                                            path: photoPath,
                                            width: photo.asset?.pixelWidth ?? Int(photo.image.size.width),
                                            height: photo.asset?.pixelHeight ?? Int(photo.image.size.height),
                                            filename: photoFilename
                                        )
                                        pickResultList.append(pickResult.toMap())
                                    }
                                    activityIndicator.stopAnimating()
                                    activityIndicator.removeFromSuperview()
                                    dispatchGroup.leave()
                                }

                            } else {
                                activityIndicator.stopAnimating()
                                activityIndicator.removeFromSuperview()
                                dispatchGroup.leave()
                            }
                        }
                    } else if photo.asset == nil {
                        dispatchGroup.leave()
                    } else {
                        photo.asset!.getURL(completionHandler: { (responseURL: URL?) in
                            if let url = responseURL {
                                var photoPath: String
                                if #available(iOS 16.0, *) {
                                    photoPath = url.path()
                                } else {
                                    photoPath = url.path
                                }
                                var width: Int
                                var height: Int
                                if photo.modifiedImage == nil {
                                    width = photo.asset!.pixelWidth
                                    height = photo.asset!.pixelHeight
                                } else {
                                    width = Int(photo.image.size.width)
                                    height = Int(photo.image.size.height)
                                }
//                                print("image:\(photo.image.size)")
//                                print("originalImage:\(photo.originalImage.size)")
//                                print("pickResult image size :\(width)*\(height)")
                                let pickResult = PhotoPickResult(
                                    id: photo.asset!.localIdentifier,
                                    path: photoPath,
                                    width: width,
                                    height: height,
                                    filename: photo.asset!.originalFilename
                                )

                                print("📷 pickResult:\(String(describing: pickResult))")
                                pickResultList.append(pickResult.toMap())
                            }
                            dispatchGroup.leave()
                        })
                    }

                case .video(v: _):
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                result(pickResultList)
                print("🤩选择了\(pickResultList.count)张照片")
                picker?.dismiss(animated: true)
                queue.asyncAfter(deadline: .now() + 20) {
                    self.selectedItems = nil
                }
            }
        }
        vc!.present(picker, animated: true, completion: nil)
    }

    func selectVideos(arguments: Any?, _ result: @escaping FlutterResult) {
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
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.albumName = bundleName
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
        config.wordings.processing = "正在处理中"
        config.wordings.warningMaxItemsLimit = "所选照片超过最大可选数量"
        config.wordings.albumsTitle = "相簿"
        config.wordings.libraryTitle = "图库"
        config.wordings.cameraTitle = "相机"
        config.wordings.videoTitle = "视频"
        config.wordings.trim = "裁剪"
        config.wordings.cover = "封面"
        config.wordings.filter = "滤镜"
        config.wordings.videoDurationPopup.title = "提示"
        config.wordings.videoDurationPopup.tooShortMessage = "录制时间过短"
        config.wordings.videoDurationPopup.tooLongMessage = "录制时间过长"
        config.wordings.permissionPopup.title = "提示"
        config.wordings.permissionPopup.message = "\(bundleName)想要访问您的媒体资源权限以用作发表推文,更新头像等操作"
        config.wordings.permissionPopup.cancel = "取消"
        config.wordings.permissionPopup.grantPermission = "允许"

        /* 颜色 */
        if let tintColor = flutterPickConfiguration.tintColor {
            let color = tintColor.uicolor()
            config.colors.tintColor = color
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
                result(nil)
                self.selectedItems = nil
                picker?.dismiss(animated: true, completion: nil)
                return
            }
//            print("🤩选择了\(items.count)条视频")
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
                        print("video:\(String(describing: video))")
                        print("video.url:\(String(describing: video.url))")
                        print("video.asset:\(String(describing: video.asset))")
                        if let result = self.saveImage(video.thumbnail) {
                            print("🔫 保存视频缩略图成功：\(result)")
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
                            var videoFilename: String

                            if let filename = video.asset?.originalFilename {
                                videoFilename = filename
                            } else {
                                videoFilename = video.url.lastPathComponent
                            }

                            videoResult = VideoPickResult(
                                videoPath: videoPath,
                                videoFilename: videoFilename,
                                duration: duration,
                                thumbnailPath: result.0,
                                thumbnailFilename: result.1,
                                thumbnailWidth: result.2,
                                thumbnailHeight: result.3
                            )
                            resultFilePathList.append(videoResult.toMap())
                            dispatchGroup.leave()
                        } else {
                            print("🤖 保存视频缩略图失败")
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                result(resultFilePathList)
                picker?.dismiss(animated: true)
                queue.asyncAfter(deadline: .now() + 20) {
                    self.selectedItems = nil
                }
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

    // MARK: - 返回路径，文件名称，宽度，高度

    func saveImage(_ image: UIImage) -> (String, String, Int, Int)? {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let randomNum = Int(arc4random_uniform(UInt32.max))
        let filename = "thumbnail_\(timestamp)_\(randomNum).jpg"
        let fileManaget = FileManager.default
        // 获取缓存目录路径
        let cacheDirectoryUrl = fileManaget.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheImageUrl = cacheDirectoryUrl.appendingPathComponent("cacheimage")
        if !fileManaget.fileExists(atPath: cacheImageUrl.path) {
            do {
                try fileManaget.createDirectory(at: cacheImageUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建路径失败")
            }
        }

        // 拼接文件路径
        let filePath: URL = cacheImageUrl.appendingPathComponent(filename)

        // 保存图片
        do {
            try image.jpegData(compressionQuality: 0.8)?.write(to: filePath, options: .atomic)
        } catch {
            print("保存图片失败: \(error.localizedDescription)")
            return nil
        }

        // 获取图片宽度和高度
        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height

        // 返回路径、宽度和高度信息
        return (filePath.path, filename, Int(round(width)), Int(round(height)))
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
                if let contentEditingInput = contentEditingInput {
                    completionHandler(contentEditingInput.fullSizeImageURL as URL?)
                } else {
                    completionHandler(nil)
                }

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
