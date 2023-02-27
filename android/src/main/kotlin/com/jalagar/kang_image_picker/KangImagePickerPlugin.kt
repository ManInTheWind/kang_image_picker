package com.jalagar.kang_image_picker

import android.net.Uri
import android.os.Build
import androidx.activity.ComponentActivity
import androidx.annotation.ChecksSdkIntAtLeast
import com.app.imagepickerlibrary.ImagePicker
import com.app.imagepickerlibrary.ImagePicker.Companion.registerImagePicker
import com.app.imagepickerlibrary.listener.ImagePickerResultListener
import com.app.imagepickerlibrary.model.PickExtension
import com.app.imagepickerlibrary.model.PickerType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

@ChecksSdkIntAtLeast(api = Build.VERSION_CODES.R)
fun isAtLeast11() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

/** KangImagePickerPlugin */
class KangImagePickerPlugin : FlutterPlugin, MethodCallHandler,
    ActivityAware,
    ImagePickerResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var imagePicker: ImagePicker? = null

    private var pickerOptions = PickerOptions.default()

    private var callback: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kang_image_picker")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "selectSinglePhoto" -> selectSinglePhoto(result)
            "selectMultiPhotos" -> selectMultiPhotos(result)
            "selectVideo" -> selectVideo(result)
            else -> result.notImplemented()
        }

    }

    private fun selectSinglePhoto(result: Result) {
        if (imagePicker == null) {
            result.error("-1", "打开失败，ImagePicker未初始化 请检查Activity是否为ComponentActivity", null)
            return
        }
        imagePicker!!
            .title("Kang Picker")
            .multipleSelection(true, 9)
            .showCountInToolBar(true)
            .showFolder(false)
            .cameraIcon(true)
            .doneIcon(true)
            .allowCropping(true)
            .compressImage(false)
            .maxImageSize(pickerOptions.maxPickSizeMB)
            .extension(PickExtension.ALL)
        if (isAtLeast11()) {
            imagePicker!!.systemPicker(false)
        }
        imagePicker!!.open(PickerType.GALLERY)
        callback = result
    }

    ///TODO:选择多个图片
    private fun selectMultiPhotos(result: Result) {

    }

    ///TODO:选择视频
    private fun selectVideo(result: Result) {

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
    }

    override fun onImagePick(uri: Uri?) {
        callback?.success(arrayListOf(uri.toString()))
    }

    override fun onMultiImagePick(uris: List<Uri>?) {
        val urls = uris?.map {
            it.toString()
        }
        if (urls != null) {
            callback?.success(urls)
        }
    }

}


