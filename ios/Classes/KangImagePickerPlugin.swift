import AVFoundation
import AVKit
import Flutter
import Photos
import UIKit
import YPImagePicker

public class KangImagePickerPlugin: NSObject, FlutterPlugin, YPImagePickerDelegate {
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
        case "openPicker":
            openPicker(result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func openPicker(_ result: @escaping FlutterResult) {
        var config = YPImagePickerConfiguration()
        let vc = getCurrentViewController()
        if vc == nil {
            result(FlutterError(code: "-1", message: "打开失败，获取FlutterViewController失败", details: nil))
            return
        }

        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */

        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
        /* 如果要强制将库输出调整为正方形图像，请将其设置为true。默认为false */
        // config.library.onlySquare = true

        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        /* 如果要强制相机输出为正方形图像，请将其设置为true。默认为true */
        // config.onlySquareImagesFromCamera = false

        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
         resized to fit in a 1024x1024 box. Defaults to original image size. */
        /* Ex：cappedTo:1024将确保库或相机中的图像重新调整大小以适合1024x1024框。默认为原始图像大小。 */
        // config.targetImageSize = .cappedTo(size: 1024)

        /* Choose what media types are available in the library. Defaults to `.photo` */
        /* 选择库中可用的媒体类型。默认为.photo */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        /* 启用默认选择前置摄像头，适用于头像。默认为false */
        /* 在拍照过程中添加滤镜步骤。默认为true */
//        config.usesFrontCamera = true

        /* Adds a Filter step in the photo taking process. Defaults to true */
        config.showsPhotoFilters = false

        /* Manage filters by yourself */
        /* 自己管理过滤器 */
        // config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                   YPFilter(name: "Normal", coreImageFilterName: "")]
        // config.filters.remove(at: 1)
        // config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)

        /* Enables you to opt out from saving new (or old but filtered) images to the
         user's photo library. Defaults to true. */
        /* 允许您选择退出保存新图像（或旧图像但经过滤处理）到用户的照片库中。默认为true。 */
        config.shouldSaveNewPicturesToAlbum = true

        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        /* 选择videoCompression。默认为AVAssetExportPresetHighestQuality */
//        config.video.compression = AVAssetExportPresetPassthrough

        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        /* 选择recordingSizeLimit。如果没有设置，则限制是时间。*/
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        /* 定义保存图片到用户的照片库中的相册名称。通常是您的应用程序名称。默认为“DefaultYPImagePickerAlbumName” */
        // config.albumName = "ThisIsMyAlbum"

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        /* 定义启动时显示哪个屏幕。只有在`showsVideo = true`时才会使用视频模式。默认值为`.photo` */
        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
         Default value is `[.library, .photo]` */
        /* 定义启动时显示哪些屏幕以及它们的顺序。
         默认值为`[.library, .photo]` */
//        config.screens = [.library, .photo, .video]
        config.screens = [.library, .photo, .video]

        /* Can forbid the items with very big height with this property */
        /* 可以使用此属性禁止具有非常大高度的项 */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Defines the time limit for recording videos.
         Default is 30 seconds. */
        /* 定义记录视频的时间限制。
         默认为30秒。 */
        // config.video.recordingTimeLimit = 5.0

        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        /* 定义库中视频的时间限制。
         默认为60秒。 */
        config.video.libraryTimeLimit = 500.0

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
//        config.showsCrop = .rectangle(ratio: 16 / 9)
        config.showsCrop = .rectangle(ratio: 4 / 3)

        /* Changes the crop mask color */
        // config.colors.cropOverlayColor = .green

        /* Defines the overlay view for the camera. Defaults to UIView(). */
        /* 定义相机的覆盖视图。默认为UIView()*/
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView

        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
//        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false

        /* Disable scroll to change between mode */
        /* 禁用滚动以更改模式 */
        // config.isScrollToChangeModesEnabled = false
        // config.library.minNumberOfItems = 2

        /* Skip selection gallery after multiple selections */
        /* 在多个选择后跳过选择库 */
        // config.library.skipSelectionsGallery = true

        /* Here we use a per picker configuration. Configuration is always shared.
         That means than when you create one picker with configuration, than you can create other picker with just
         let picker = YPImagePicker() and the configuration will be the same as the first picker. */
        /* 在这里，我们使用每个选择器配置。配置始终是共享的。
         这意味着当您创建带有配置的一个选择器时，您可以仅创建其他选择器
         let picker = YPImagePicker()，并且配置与第一个选择器相同。*/

        /* Only show library pictures from the last 3 days */
        /* 仅显示最近 3 天的库图片 */
        // let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        // let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        // let toDate = Date()
        // let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        /// 只是一种设置顺序的方式
        // let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        // options.sortDescriptors = [sortDescriptor]
        //
        // config.library.options = options

        /// 选择过的
        // config.library.preselectedItems = selectedItems

        // Customise fonts
        // 自定义字体
        // config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        // config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        // config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        // config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        // config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)

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
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }

            //            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    //                    self.selectedImageV.image = photo.image
                    
                    picker?.dismiss(animated: true, completion: nil)
                case .video(let video):
                    //                    self.selectedImageV.image = video.thumbnail

                    let assetURL = video.url
                    let playerVC = AVPlayerViewController()
                    let player = AVPlayer(playerItem: AVPlayerItem(url: assetURL))
                    playerVC.player = player

                    picker?.dismiss(animated: true, completion: { [weak self] in
                        vc?.present(playerVC, animated: true, completion: nil)
                        print("😀 \(assetURL)")
                    })
                }
            }
        }

        /* Single Photo implementation. */
//        picker.didFinishPicking { [weak picker] items, _ in
        ////             self.selectedItems = items
        ////             self.selectedImageV.image = items.singlePhoto?.image
//            let image = items.singlePhoto?.image;
//
//            print("😀 \(String(describing: items.singlePhoto?.image))")
//            let photo = YPMediaPhoto(image: image!, asset: nil)
//            photo.asset?.getURL(completionHandler: { url in
//                print("🔫 \(String(describing: url))")
//            })
//            picker?.dismiss(animated: true, completion: nil)
//        }

        /* Single Video implementation. */
        // picker.didFinishPicking { [weak picker] items, cancelled in
        //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
        //
        //    self.selectedItems = items
        //    self.selectedImageV.image = items.singleVideo?.thumbnail
        //
        //    let assetURL = items.singleVideo!.url
        //    let playerVC = AVPlayerViewController()
        //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
        //    playerVC.player = player
        //
        //    picker.dismiss(animated: true, completion: { [weak self] in
        //        self?.present(playerVC, animated: true, completion: nil)
        //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
        //    })
        // }

        vc!.present(picker, animated: true, completion: nil)
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
