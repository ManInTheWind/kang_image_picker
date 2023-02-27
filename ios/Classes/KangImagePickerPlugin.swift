import AVFoundation
import AVKit
import Flutter
import Photos
import UIKit
import YPImagePicker

public class KangImagePickerPlugin: NSObject, FlutterPlugin, YPImagePickerDelegate {
//    private var FLUTTER_CANCEL_CODE: String = "-2"
//    private var FLUTTER_SELECTED_BUT_NOT_FOUND_CODE: String = "-2"

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
            selectSinglePhoto(result)
        case "selectMultiPhotos":
            selectMultiPhotos(result)
        case "selectVideo":
            selectVideo(result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func selectSinglePhoto(_ result: @escaping FlutterResult) {
        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(FlutterError(code: "-1", message: "打开失败，获取FlutterViewController失败", details: nil))
            return
        }
        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        /* Adds a Filter step in the photo taking process. Defaults to true */
        /* 在拍照过程中添加滤镜步骤。默认为true */
        config.showsPhotoFilters = false
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
        config.showsPhotoFilters = true

        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */
        config.startOnScreen = .library

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = [.library, .photo]

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .rectangle(ratio: 4/3)

        /* 颜色 */
        config.colors.tintColor = "#2BD180".uicolor()

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false

        /// 选择过的
//         config.library.preselectedItems = selectedItems

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
                    let fetchAsset: PHAsset? = self.getPHAsset(for: photo.originalImage, inAlbumNamed: albumName)
                    print("🥹 找到了\(String(describing: fetchAsset))")
                    if let modifiedImage = photo.modifiedImage {
                        let fetchAsset1: PHAsset? = self.getPHAsset(for: modifiedImage, inAlbumNamed: albumName)
                        print("🥹 找到了1 \(String(describing: fetchAsset1))")
                    }
                    let fetchAsset2: PHAsset? = self.getPHAsset(for: photo.image, inAlbumNamed: albumName)
                    print("🥹 找到了2 \(String(describing: fetchAsset2))")
                    if fetchAsset == nil {
                        result(self.getFlutterDefaultError(msg: "无法找到用户选择的图片"))
                    } else {
                        fetchAsset!.getURL(completionHandler: { (responseURL: URL?) in
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

    func selectMultiPhotos(_ result: @escaping FlutterResult) {
        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(getFlutterDefaultError(msg: "打开失败，获取FlutterViewController失败"))
            return
        }

        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        /* Adds a Filter step in the photo taking process. Defaults to true */
        /* 在拍照过程中添加滤镜步骤。默认为true */
        config.showsPhotoFilters = false
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */
        config.shouldSaveNewPicturesToAlbum = true

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        config.albumName = Bundle.main.infoDictionary!["CFBundleName"] as! String

        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */
        config.startOnScreen = .library

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = [.library, .photo]

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        /* 是否开启裁剪，以及裁剪比例，默认.none */
        config.showsCrop = .rectangle(ratio: 4/3)

        /* 颜色 */
        config.colors.tintColor = "#2BD180".uicolor()

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 9
        config.gallery.hidesRemoveButton = false

        /// 选择过的
        // config.library.preselectedItems = selectedItems

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

            var resultFilePathList = [String]()
            let dispatchGroup = DispatchGroup()
            for item: YPMediaItem in items {
                dispatchGroup.enter()
                switch item {
                case .photo(p: let photo):

                    if photo.asset == nil {
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

    func selectVideo(_ result: @escaping FlutterResult) {
        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(getFlutterDefaultError(msg: "打开失败，获取FlutterViewController失败"))
            return
        }

        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        config.showsPhotoFilters = false
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */

        /* 选择videoCompression。默认为AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough
        /* 选择recordingSizeLimit。如果没有设置，则限制是时间。*/
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        // config.albumName = "ThisIsMyAlbum"
        config.albumName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        config.shouldSaveNewPicturesToAlbum = true

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */

        config.startOnScreen = .video

        /* 定义启动时显示哪些屏幕以及它们的顺序。默认值为`[.library, .photo]` */
        config.screens = [.video, .library]

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* 定义记录视频的时间限制。默认为30秒。 */
        config.video.recordingTimeLimit = 30.0

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
        config.colors.tintColor = "#2BD180".uicolor()

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 5

        config.gallery.hidesRemoveButton = false

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

            let thumbnailImage: UIImage? = items.singleVideo?.thumbnail

            /// file:///private/var/mobile/Containers/Data/Application/95B7E022-6A7D-4083-83E9-BD897A100BE0/tmp/51FE6CF9-6FB1-426E-A938-4610664EE907.mov

            let assetURL = items.singleVideo!.url

            let playerVC = AVPlayerViewController()

            let player = AVPlayer(playerItem: AVPlayerItem(url: assetURL))

            playerVC.player = player

            picker?.dismiss(animated: true, completion: { [weak self] in

                vc?.present(playerVC, animated: true, completion: nil)

                print("😀 \(String(describing: assetURL))")
            })

//            picker?.dismiss(animated: true)
//
//            guard let video:YPMediaVideo =  items.singleVideo else{
//                result(self.getFlutterSelectedButNotFoundError())
//                return
//            }
//
//            guard let videoAsset:PHAsset = video.asset else {
//                result(self.getFlutterSelectedButNotFoundError())
//                return
//            }
//
//            videoAsset.getURL { responseURL in
//                if responseURL == nil {
//                    result(self.getFlutterSelectedButNotFoundError())
//                    return
//                }
//                if #available(iOS 16.0, *) {
//                    result(responseURL?.path())
//                } else {
//                    result(responseURL?.path)
//                }
//            }
        }

        vc!.present(picker, animated: true, completion: nil)
    }

    func getPHAsset(for image: UIImage, inAlbumNamed albumName: String) -> PHAsset? {
        var resultAsset: PHAsset?
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let albumFetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        albumFetchResult.enumerateObjects { assetCollection, _, stop in
            if assetCollection.localizedTitle == albumName {
                let assets = PHAsset.fetchAssets(in: assetCollection, options: options)
                assets.enumerateObjects { asset, _, stop in
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .highQualityFormat

                    PHImageManager.default().requestImageData(for: asset, options: requestOptions) { imageData, _, _, _ in
                        if let imageData = imageData, let checkImage = UIImage(data: imageData), checkImage == image {
                            resultAsset = asset
                            stop.pointee = true
                        }
                    }
                }
            }
        }
        return resultAsset
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
