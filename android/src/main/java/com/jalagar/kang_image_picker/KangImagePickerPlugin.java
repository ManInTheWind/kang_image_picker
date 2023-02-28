package com.jalagar.kang_image_picker;

//import static android.provider.Settings.System.getString;

import android.content.Context.*;


import android.app.Activity;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Pair;

import androidx.activity.ComponentActivity;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.luck.picture.lib.basic.PictureSelector;
import com.luck.picture.lib.config.SelectMimeType;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.interfaces.OnResultCallbackListener;
import com.luck.picture.lib.style.BottomNavBarStyle;
import com.luck.picture.lib.style.PictureSelectorStyle;
import com.luck.picture.lib.style.PictureWindowAnimationStyle;
import com.luck.picture.lib.style.SelectMainStyle;
import com.luck.picture.lib.style.TitleBarStyle;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

//@ChecksSdkIntAtLeast(api = Build.VERSION_CODES.R)
//fun isAtLeast11() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

/**
 * KangImagePickerPlugin
 */
public class KangImagePickerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private Activity mActivity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "kang_image_picker");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "selectSinglePhoto":
                selectSinglePhoto(result);
                break;
            case "selectMultiPhotos":
                selectMultiPhotos(result);
                break;
            case "selectVideo":
                selectVideo(result);
                break;
            default:
                result.notImplemented();
        }
    }


    private void selectSinglePhoto(Result result) {

        PictureSelector.create(mActivity)
                .openGallery(SelectMimeType.ofImage())
                .setImageEngine(GlideEngine.createGlideEngine())
                .setSelectorUIStyle(getSelectorStyle())


                .forResult(new OnResultCallbackListener<LocalMedia>() {
                    @Override
                    public void onResult(ArrayList<LocalMedia> pickResult) {
                        // 处理返回结果
                        String res = getPathFromUri(mActivity, Uri.parse(pickResult.get(0).getPath()));
                        result.success(res);
                    }

                    @Override
                    public void onCancel() {
                        // 处理取消操作
                        Pair<String, String> flutterCancelError = getFlutterCancelError();
                        result.error(flutterCancelError.first, flutterCancelError.second, null);
                    }
                });

    }


    private void selectVideo(Result result) {
    }

    private void selectMultiPhotos(Result result) {
    }

    private PictureSelectorStyle getSelectorStyle() {
        PictureSelectorStyle selectorStyle = new PictureSelectorStyle();
        TitleBarStyle whiteTitleBarStyle = new TitleBarStyle();
        whiteTitleBarStyle.setTitleBackgroundColor(ContextCompat.getColor(getContext(), R.color.ps_color_white));
        whiteTitleBarStyle.setTitleDrawableRightResource(R.drawable.ic_arrow_down);
        whiteTitleBarStyle.setTitleLeftBackResource(R.drawable.ps_ic_black_back);
        whiteTitleBarStyle.setTitleTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_black));
        whiteTitleBarStyle.setTitleCancelTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_53575e));
        whiteTitleBarStyle.setDisplayTitleBarLine(true);

        BottomNavBarStyle whiteBottomNavBarStyle = new BottomNavBarStyle();
        whiteBottomNavBarStyle.setBottomNarBarBackgroundColor(Color.parseColor("#EEEEEE"));
        whiteBottomNavBarStyle.setBottomPreviewSelectTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_53575e));

        whiteBottomNavBarStyle.setBottomPreviewNormalTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_9b));
        whiteBottomNavBarStyle.setBottomPreviewSelectTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_20c064));
        whiteBottomNavBarStyle.setCompleteCountTips(false);
        whiteBottomNavBarStyle.setBottomEditorTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_53575e));
        whiteBottomNavBarStyle.setBottomOriginalTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_53575e));

        SelectMainStyle selectMainStyle = new SelectMainStyle();
        selectMainStyle.setStatusBarColor(ContextCompat.getColor(getContext(), R.color.ps_color_white));
        selectMainStyle.setDarkStatusBarBlack(true);
        selectMainStyle.setSelectNormalTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_9b));
        selectMainStyle.setSelectTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_20c064));
        selectMainStyle.setPreviewSelectBackground(R.drawable.ps_demo_white_preview_selector);
        selectMainStyle.setSelectBackground(R.drawable.ps_checkbox_selector);
        selectMainStyle.setSelectText(getContext().getString(R.string.ps_done_front_num));
        selectMainStyle.setMainListBackgroundColor(ContextCompat.getColor(getContext(), R.color.ps_color_white));

        selectorStyle.setTitleBarStyle(whiteTitleBarStyle);
        selectorStyle.setBottomBarStyle(whiteBottomNavBarStyle);
        selectorStyle.setSelectMainStyle(selectMainStyle);

        //动画
        PictureWindowAnimationStyle animationStyle = new PictureWindowAnimationStyle();
        animationStyle.setActivityEnterAnimation(R.anim.ps_anim_up_in);
        animationStyle.setActivityExitAnimation(R.anim.ps_anim_down_out);
        selectorStyle.setWindowAnimationStyle(animationStyle);
        return selectorStyle;
    }

    private Context getContext() {
        return mActivity;
    }


    private Pair<String, String> getFlutterDefaultError(String msg) {
        if (msg == null) {
            msg = "操作失败";
        }
        return new Pair<>("-1", msg);
    }

    private Pair<String, String> getFlutterCancelError() {
        return new Pair<>("-2", "用户取消选择");
    }

    private Pair<String, String> getFlutterSelectedButNotFoundError() {
        return new Pair<>("-3", "找不到用户选择的资源");
    }


//    override fun onImagePick(uri: Uri?) {
//        var path:String? = null
//        if (uri != null){
//            path = getPathFromUri(context,uri)
//        }
//        callback?.success(path)
//    }

//    override fun onMultiImagePick(uris: List<Uri>?) {
//        var paths: MutableList<String>? = null
//        if (uris != null){
//            paths = mutableListOf();
//            for (uri in uris){
//                val pathFromUri = getPathFromUri(context, uri)
//                if (pathFromUri != null){
//                    paths.add(pathFromUri)
//                }
//            }
//        }
//        callback?.success(paths)
//    }

    private String getPathFromUri(Context context, Uri uri) {
        String[] projection = {MediaStore.Images.Media.DATA};
        Cursor cursor = context.getContentResolver().query(uri, projection, null, null, null);
        int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
        cursor.moveToFirst();
        String path = cursor.getString(columnIndex);
        cursor.close();
        return path;
    }


}


