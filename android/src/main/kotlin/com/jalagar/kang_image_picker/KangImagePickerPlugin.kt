package com.jalagar.kang_image_picker

import android.net.Uri
import android.os.Build
import androidx.activity.ComponentActivity
import androidx.annotation.ChecksSdkIntAtLeast
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.app.imagepickerlibrary.ImagePicker
import com.app.imagepickerlibrary.ImagePicker.Companion.registerImagePicker
import com.app.imagepickerlibrary.listener.ImagePickerResultListener
import com.app.imagepickerlibrary.model.PickExtension
import com.app.imagepickerlibrary.model.PickerType
import io.flutter.embedding.android.FlutterFragmentActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
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

    private lateinit var binding: FlutterPluginBinding

    private var imagePicker: ImagePicker? = null

    private var pickerOptions = PickerOptions.default()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kang_image_picker")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "openPicker" -> openPicker(result)
            else -> result.notImplemented()
        }

    }


    private fun openPicker(result: Result) {

        if (imagePicker == null) {
            result.error("-1", "打开失败，ImagePicker未初始化", null)
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
        result.success(true)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    override fun onImagePick(uri: Uri?) {
    }

    override fun onMultiImagePick(uris: List<Uri>?) {
    }


}


