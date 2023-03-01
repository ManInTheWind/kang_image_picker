package com.jalagar.kang_image_picker;

//import static android.provider.Settings.System.getString;

import static com.luck.picture.lib.thread.PictureThreadUtils.runOnUiThread;

import android.Manifest;
import android.app.Dialog;
import android.content.Context.*;


import android.app.Activity;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.CalendarContract;
import android.provider.MediaStore;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.util.Pair;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.activity.ComponentActivity;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.AspectRatio;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;
import com.luck.lib.camerax.CameraImageEngine;
import com.luck.lib.camerax.SimpleCameraX;
import com.luck.lib.camerax.listener.OnSimpleXPermissionDeniedListener;
import com.luck.lib.camerax.listener.OnSimpleXPermissionDescriptionListener;
import com.luck.lib.camerax.permissions.SimpleXPermissionUtil;
import com.luck.picture.lib.basic.PictureSelectionModel;
import com.luck.picture.lib.basic.PictureSelector;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.config.SelectMimeType;
import com.luck.picture.lib.dialog.RemindDialog;
import com.luck.picture.lib.engine.CropFileEngine;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.entity.MediaExtraInfo;
import com.luck.picture.lib.interfaces.OnCameraInterceptListener;
import com.luck.picture.lib.interfaces.OnCustomLoadingListener;
import com.luck.picture.lib.interfaces.OnResultCallbackListener;
import com.luck.picture.lib.permissions.PermissionConfig;
import com.luck.picture.lib.style.BottomNavBarStyle;
import com.luck.picture.lib.style.PictureSelectorStyle;
import com.luck.picture.lib.style.PictureWindowAnimationStyle;
import com.luck.picture.lib.style.SelectMainStyle;
import com.luck.picture.lib.style.TitleBarStyle;
import com.luck.picture.lib.utils.DensityUtil;
import com.luck.picture.lib.utils.MediaUtils;
import com.luck.picture.lib.utils.PictureFileUtils;
import com.luck.picture.lib.utils.StyleUtils;
import com.luck.picture.lib.widget.MediumBoldTextView;
import com.yalantis.ucrop.UCrop;
import com.yalantis.ucrop.UCropImageEngine;

import org.json.JSONException;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


/**
 * KangImagePickerPlugin
 */
public class KangImagePickerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private final static String TAG_EXPLAIN_VIEW = "TAG_EXPLAIN_VIEW";

    private final static String TAG = KangImagePickerPlugin.class.getSimpleName();
    private MethodChannel channel;

    private Activity mActivity;

    private PictureSelectorStyle selectorStyle;

    private FlutterPickerConfiguration flutterPickerConfiguration;

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
                selectSinglePhoto(call.arguments, result);
                break;
            case "selectMultiPhotos":
                selectMultiPhotos(call.arguments, result);
                break;
            case "selectVideo":
                selectVideo(call.arguments, result);
                break;
            default:
                result.notImplemented();
        }
    }


    private void selectSinglePhoto(Object arguments, Result result) {
        Log.i(TAG, "arguments:" + arguments);
        if (arguments != null) {
            try {
                flutterPickerConfiguration = FlutterPickerConfiguration.fromObject(arguments);
            } catch (JSONException e) {
                Pair<String, String> flutterDefaultError = getFlutterDefaultError("参数不正确");
                result.error(flutterDefaultError.first, flutterDefaultError.second, e.getStackTrace());
                return;
            }
        } else {
            flutterPickerConfiguration = FlutterPickerConfiguration.defaultConfiguration();
        }
        Log.i(TAG, "flutterPickerConfiguration:" + flutterPickerConfiguration);
        if (selectorStyle == null) {
            selectorStyle = getSelectorStyle(flutterPickerConfiguration.getTintColor());
        }
        PictureSelectionModel pictureSelector = PictureSelector.create(mActivity).openGallery(flutterPickerConfiguration.getMediaType())
                .setImageEngine(GlideEngine.createGlideEngine())
                .setSelectorUIStyle(selectorStyle)
                .setCameraInterceptListener(new MeOnCameraInterceptListener())
                .setMaxSelectNum(flutterPickerConfiguration.getMaxNumberOfItems());
        if (flutterPickerConfiguration.getCropRatio() != null) {
            CropRatio cropRatio = CropRatio.fromValue(flutterPickerConfiguration.getCropRatio());
            pictureSelector.setCropEngine(new ImageFileCropEngine(cropRatio));
        }
        pictureSelector.forResult(new OnResultCallbackListener<LocalMedia>() {
            @Override
            public void onResult(ArrayList<LocalMedia> pickResult) {
                // 处理返回结果
                result.success(pickResult.get(0).getCutPath());
            }

            @Override
            public void onCancel() {
                // 处理取消操作
                Pair<String, String> flutterCancelError = getFlutterCancelError();
                result.error(flutterCancelError.first, flutterCancelError.second, null);
            }
        });
    }

    private void selectMultiPhotos(Object arguments, Result result) {
        FlutterPickerConfiguration flutterPickerConfiguration;
        if (arguments != null) {
            try {
                flutterPickerConfiguration = FlutterPickerConfiguration.fromObject(arguments);
            } catch (JSONException e) {
                Pair<String, String> flutterDefaultError = getFlutterDefaultError("参数不正确");
                result.error(flutterDefaultError.first, flutterDefaultError.second, e.getStackTrace());
                return;
            }
        } else {
            flutterPickerConfiguration = FlutterPickerConfiguration.defaultConfiguration();
        }
        if (selectorStyle == null) {
            selectorStyle = getSelectorStyle(flutterPickerConfiguration.getTintColor());
        }

        PictureSelector.create(mActivity)
                .openGallery(flutterPickerConfiguration.getMediaType())
                .setImageEngine(GlideEngine.createGlideEngine())
                .setSelectorUIStyle(selectorStyle)
                .setCameraInterceptListener(new MeOnCameraInterceptListener())
                .setMaxSelectNum(flutterPickerConfiguration.getMaxNumberOfItems())
                .forResult(new OnResultCallbackListener<LocalMedia>() {
                    @Override
                    public void onResult(ArrayList<LocalMedia> pickResult) {
                        analyticalSelectResults(pickResult);
                        List<String> paths = new ArrayList<>();
                        for (LocalMedia localMedia : pickResult) {
                            // 处理返回结果
                            paths.add(localMedia.getRealPath());
                        }
                        result.success(paths);
                    }

                    @Override
                    public void onCancel() {
                        // 处理取消操作
                        Pair<String, String> flutterCancelError = getFlutterCancelError();
                        result.error(flutterCancelError.first, flutterCancelError.second, null);
                    }
                });
    }


    private void selectVideo(Object arguments, Result result) {
        FlutterPickerConfiguration flutterPickerConfiguration;
        if (arguments != null) {
            try {
                flutterPickerConfiguration = FlutterPickerConfiguration.fromObject(arguments);
            } catch (JSONException e) {
                Pair<String, String> flutterDefaultError = getFlutterDefaultError("参数不正确");
                result.error(flutterDefaultError.first, flutterDefaultError.second, e.getStackTrace());
                return;
            }
        } else {
            flutterPickerConfiguration = FlutterPickerConfiguration.defaultConfiguration();
        }
        if (selectorStyle == null) {
            selectorStyle = getSelectorStyle(flutterPickerConfiguration.getTintColor());
        }
        PictureSelector.create(mActivity)
                .openGallery(SelectMimeType.ofVideo())
                .setImageEngine(GlideEngine.createGlideEngine())
                .setSelectorUIStyle(selectorStyle)
                .setCameraInterceptListener(new MeOnCameraInterceptListener())
                .setMaxSelectNum(1)
                .setRecordVideoMaxSecond(flutterPickerConfiguration.getVideoRecordingTimeLimit())
                .setSelectMaxDurationSecond(flutterPickerConfiguration.getTrimmerMaxDuration())
                .setCustomLoadingListener(getCustomLoadingListener())
                .setVideoPlayerEngine(new IjkPlayerEngine())
                .forResult(new OnResultCallbackListener<LocalMedia>() {
                    @Override
                    public void onResult(ArrayList<LocalMedia> pickResult) {
                        analyticalSelectResults(pickResult);
                        LocalMedia localMedia = pickResult.get(0);
                        // 处理返回结果

                        if (localMedia.getVideoThumbnailPath() == null) {
                            getThumbnailAsync(getContext(), localMedia.getPath(), new ThumbnailCallback() {
                                @Override
                                public void onThumbnailReady(String thumbnailPath) {
                                    Log.i(TAG, "加载缩略图完成: " + thumbnailPath);
                                    Map<String, Object> videoSelectResultMap = new HashMap<>();
                                    videoSelectResultMap.put("videoPath", localMedia.getRealPath());
                                    videoSelectResultMap.put("thumbnailPath", thumbnailPath);
                                    videoSelectResultMap.put("thumbnailWidth", ((double) localMedia.getWidth()));
                                    videoSelectResultMap.put("thumbnailHeight", ((double) localMedia.getWidth()));
                                    videoSelectResultMap.put("duration", ((double) localMedia.getDuration()));
                                    result.success(videoSelectResultMap);
                                }

                                @Override
                                public void onThumbnailFailed() {
                                    Log.e(TAG, "加载缩略图失败");
                                    Pair<String, String> flutterCancelError = getFlutterDefaultError("加载视频缩略图的时候出现了错误");
                                    result.error(flutterCancelError.first, flutterCancelError.second, null);
                                }
                            });
                        } else {
                            Map<String, Object> videoSelectResultMap = new HashMap<>();
                            videoSelectResultMap.put("videoPath", localMedia.getRealPath());
                            videoSelectResultMap.put("thumbnailPath", localMedia.getVideoThumbnailPath());
                            videoSelectResultMap.put("thumbnailWidth", ((double) localMedia.getWidth()));
                            videoSelectResultMap.put("thumbnailHeight", ((double) localMedia.getWidth()));
                            videoSelectResultMap.put("duration", ((double) localMedia.getDuration()));
                            result.success(videoSelectResultMap);
                        }
                    }

                    @Override
                    public void onCancel() {
                        // 处理取消操作
                        Pair<String, String> flutterCancelError = getFlutterCancelError();
                        result.error(flutterCancelError.first, flutterCancelError.second, null);
                    }
                });
    }


    /**
     * 自定义裁剪
     */
    private class ImageFileCropEngine implements CropFileEngine {

        private CropRatio cropRatio;

        public ImageFileCropEngine(CropRatio cropRatio) {
            this.cropRatio = cropRatio;
        }

        @Override
        public void onStartCrop(Fragment fragment, Uri srcUri, Uri destinationUri, ArrayList<String> dataSource, int requestCode) {
            UCrop.Options options = buildOptions();
            UCrop uCrop = UCrop.of(srcUri, destinationUri, dataSource);
            uCrop.withOptions(options);
            uCrop.setImageEngine(new UCropImageEngine() {
                @Override
                public void loadImage(Context context, String url, ImageView imageView) {
                    if (!ImageLoaderUtils.assertValidRequest(context)) {
                        return;
                    }
                    Glide.with(context).load(url).override(180, 180).into(imageView);
                }

                @Override
                public void loadImage(Context context, Uri url, int maxWidth, int maxHeight, OnCallbackListener<Bitmap> call) {
                    Glide.with(context).asBitmap().load(url).override(maxWidth, maxHeight).into(new CustomTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                            if (call != null) {
                                call.onCall(resource);
                            }
                        }

                        @Override
                        public void onLoadCleared(@Nullable Drawable placeholder) {
                            if (call != null) {
                                call.onCall(null);
                            }
                        }
                    });
                }
            });
            uCrop.start(fragment.requireActivity(), fragment, requestCode);
        }

        private UCrop.Options buildOptions() {
            UCrop.Options options = new UCrop.Options();
            options.setHideBottomControls(false);
            options.setFreeStyleCropEnabled(false);
            options.setShowCropFrame(true);
            options.setShowCropGrid(true);
            options.setCircleDimmedLayer(false);
            options.withAspectRatio(cropRatio.getX(), cropRatio.getY());

//        options.setCropOutputPathDir(getSandboxPath());
            options.isCropDragSmoothToCenter(false);
            options.setSkipCropMimeType(PictureMimeType.ofGIF(), PictureMimeType.ofWEBP());
            options.isForbidCropGifWebp(true);
            options.isForbidSkipMultipleCrop(true);
            options.setMaxScaleMultiplier(100);
            if (selectorStyle != null && selectorStyle.getSelectMainStyle().getStatusBarColor() != 0) {
                SelectMainStyle mainStyle = selectorStyle.getSelectMainStyle();
                boolean isDarkStatusBarBlack = mainStyle.isDarkStatusBarBlack();
                int statusBarColor = mainStyle.getStatusBarColor();
                options.isDarkStatusBarBlack(isDarkStatusBarBlack);
                if (StyleUtils.checkStyleValidity(statusBarColor)) {
                    options.setStatusBarColor(statusBarColor);
                    options.setToolbarColor(statusBarColor);
                } else {
                    options.setStatusBarColor(ContextCompat.getColor(getContext(), R.color.ps_color_grey));
                    options.setToolbarColor(ContextCompat.getColor(getContext(), R.color.ps_color_grey));
                }
                TitleBarStyle titleBarStyle = selectorStyle.getTitleBarStyle();
                if (StyleUtils.checkStyleValidity(titleBarStyle.getTitleTextColor())) {
                    options.setToolbarWidgetColor(titleBarStyle.getTitleTextColor());
                } else {
                    options.setToolbarWidgetColor(ContextCompat.getColor(getContext(), R.color.ps_color_white));
                }
            } else {
                options.setStatusBarColor(ContextCompat.getColor(getContext(), R.color.ps_color_grey));
                options.setToolbarColor(ContextCompat.getColor(getContext(), R.color.ps_color_grey));
                options.setToolbarWidgetColor(ContextCompat.getColor(getContext(), R.color.ps_color_white));
            }
            return options;
        }
    }


    /**
     * 创建自定义输出目录
     *
     * @return
     */
    private String getVideoThumbnailDir() {
        File externalFilesDir = getContext().getExternalFilesDir("");
        File customFile = new File(externalFilesDir.getAbsolutePath(), "Thumbnail");
        if (!customFile.exists()) {
            customFile.mkdirs();
        }
        return customFile.getAbsolutePath() + File.separator;
    }

    /**
     * 自定义UI
     * color:主题颜色
     */
    private PictureSelectorStyle getSelectorStyle(String color) {
        ///主题颜色
        int tintColor;
        if (color == null) {
            color = "#2BD180";
        }
        tintColor = Color.parseColor(color);
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
        whiteBottomNavBarStyle.setBottomPreviewSelectTextColor(tintColor);
        whiteBottomNavBarStyle.setCompleteCountTips(false);
        whiteBottomNavBarStyle.setBottomEditorTextColor(tintColor);
        whiteBottomNavBarStyle.setBottomOriginalTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_53575e));

        SelectMainStyle selectMainStyle = new SelectMainStyle();
        selectMainStyle.setStatusBarColor(ContextCompat.getColor(getContext(), R.color.ps_color_white));
        selectMainStyle.setDarkStatusBarBlack(true);
        selectMainStyle.setSelectNormalTextColor(ContextCompat.getColor(getContext(), R.color.ps_color_9b));
        selectMainStyle.setSelectTextColor(tintColor);
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

    /**
     * 自定义拍照
     */
    private class MeOnCameraInterceptListener implements OnCameraInterceptListener {


        @Override
        public void openCamera(Fragment fragment, int cameraMode, int requestCode) {
            SimpleCameraX camera = SimpleCameraX.of();
            camera.isAutoRotation(true);
            camera.setCameraMode(cameraMode);
            camera.setVideoFrameRate(25);
            camera.setVideoBitRate(3 * 1024 * 1024);
            camera.isDisplayRecordChangeTime(true);
            ///TODO:设置为tineColor
            if (flutterPickerConfiguration != null && flutterPickerConfiguration.getTintColor() != null) {
                camera.setCaptureLoadingColor(Color.parseColor(flutterPickerConfiguration.getTintColor()));
            }
            //手指点击聚焦
            camera.isManualFocusCameraPreview(true);
            //手机缩放相机
            camera.isZoomCameraPreview(true);
            //自定义路径
            // camera.setOutputPathDir(getSandboxCameraOutputPath());
            camera.setPermissionDeniedListener(new MeOnSimpleXPermissionDeniedListener());
            camera.setPermissionDescriptionListener(new MeOnSimpleXPermissionDescriptionListener());
            camera.setImageEngine(new CameraImageEngine() {
                @Override
                public void loadImage(Context context, String url, ImageView imageView) {
                    Glide.with(context).load(url).into(imageView);
                }
            });
            camera.start(fragment.requireActivity(), fragment, requestCode);
        }
    }

    /**
     * 创建自定义输出目录
     *
     * @return
     */
    private String getSandboxPath() {
        File externalFilesDir = getContext().getExternalFilesDir("");
        File customFile = new File(externalFilesDir.getAbsolutePath(), "Sandbox");
        if (!customFile.exists()) {
            customFile.mkdirs();
        }
        return customFile.getAbsolutePath() + File.separator;
    }

    /**
     * 创建相机自定义输出目录
     *
     * @return
     */
    private String getSandboxCameraOutputPath() {
        File externalFilesDir = getContext().getExternalFilesDir("");
        File customFile = new File(externalFilesDir.getAbsolutePath(), "Sandbox");
        if (!customFile.exists()) {
            customFile.mkdirs();
        }
        return customFile.getAbsolutePath() + File.separator;
    }

    public void getThumbnailAsync(Context context, String videoPath, ThumbnailCallback callback) {
        Glide.with(context)
                .asBitmap()
                .load(videoPath)
                .into(new CustomTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        resource.compress(Bitmap.CompressFormat.JPEG, 60, stream);
                        FileOutputStream fos = null;
                        String result = null;
                        String targetPath = getVideoThumbnailDir();
                        try {
                            File targetFile = new File(targetPath, "thumbnails_" + System.currentTimeMillis() + ".jpg");
                            fos = new FileOutputStream(targetFile);
                            fos.write(stream.toByteArray());
                            fos.flush();
                            result = targetFile.getAbsolutePath();
                        } catch (IOException e) {
                            e.printStackTrace();
                        } finally {
                            PictureFileUtils.close(fos);
                            PictureFileUtils.close(stream);
                        }
                        // 处理缩略图
                        callback.onThumbnailReady(result);
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        // 未加载成功时的处理
                        callback.onThumbnailFailed();
                    }
                });
    }

    private interface ThumbnailCallback {
        void onThumbnailReady(String thumbnailPath);

        void onThumbnailFailed();
    }


    /**
     * SimpleCameraX添加权限说明
     */
    private static class MeOnSimpleXPermissionDeniedListener implements OnSimpleXPermissionDeniedListener {

        @Override
        public void onDenied(Context context, String permission, int requestCode) {
            String tips;
            if (TextUtils.equals(permission, Manifest.permission.RECORD_AUDIO)) {
                tips = "缺少麦克风权限\n可能会导致录视频无法采集声音";
            } else {
                tips = "缺少相机权限\n可能会导致不能使用摄像头功能";
            }
            RemindDialog dialog = RemindDialog.buildDialog(context, tips);
            dialog.setButtonText("去设置");
            dialog.setButtonTextColor(0xFF7D7DFF);
            dialog.setContentTextColor(0xFF333333);
            dialog.setOnDialogClickListener(new RemindDialog.OnDialogClickListener() {
                @Override
                public void onClick(View view) {
                    SimpleXPermissionUtil.goIntentSetting((Activity) context, requestCode);
                    dialog.dismiss();
                }
            });
            dialog.show();
        }
    }

    /**
     * SimpleCameraX添加权限说明
     */
    private static class MeOnSimpleXPermissionDescriptionListener implements OnSimpleXPermissionDescriptionListener {

        @Override
        public void onPermissionDescription(Context context, ViewGroup viewGroup, String permission) {
            addPermissionDescription(true, viewGroup, new String[]{permission});
        }

        @Override
        public void onDismiss(ViewGroup viewGroup) {
            removePermissionDescription(viewGroup);
        }
    }

    /**
     * 添加权限说明
     *
     * @param viewGroup
     * @param permissionArray
     */
    private static void addPermissionDescription(boolean isHasSimpleXCamera, ViewGroup viewGroup, String[] permissionArray) {
        int dp10 = DensityUtil.dip2px(viewGroup.getContext(), 10);
        int dp15 = DensityUtil.dip2px(viewGroup.getContext(), 15);
        MediumBoldTextView view = new MediumBoldTextView(viewGroup.getContext());
        view.setTag(TAG_EXPLAIN_VIEW);
        view.setTextSize(14);
        view.setTextColor(Color.parseColor("#333333"));
        view.setPadding(dp10, dp15, dp10, dp15);

        String title;
        String explain;

        if (TextUtils.equals(permissionArray[0], PermissionConfig.CAMERA[0])) {
            title = "相机权限使用说明";
            explain = "相机权限使用说明\n用户app用于拍照/录视频";
        } else if (TextUtils.equals(permissionArray[0], Manifest.permission.RECORD_AUDIO)) {
            if (isHasSimpleXCamera) {
                title = "麦克风权限使用说明";
                explain = "麦克风权限使用说明\n用户app用于录视频时采集声音";
            } else {
                title = "录音权限使用说明";
                explain = "录音权限使用说明\n用户app用于采集声音";
            }
        } else {
            title = "存储权限使用说明";
            explain = "存储权限使用说明\n用户app写入/下载/保存/读取/修改/删除图片、视频、文件等信息";
        }
        int startIndex = 0;
        int endOf = startIndex + title.length();
        SpannableStringBuilder builder = new SpannableStringBuilder(explain);
        builder.setSpan(new AbsoluteSizeSpan(DensityUtil.dip2px(viewGroup.getContext(), 16)), startIndex, endOf, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        builder.setSpan(new ForegroundColorSpan(0xFF333333), startIndex, endOf, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        view.setText(builder);
        view.setBackground(ContextCompat.getDrawable(viewGroup.getContext(), R.drawable.ps_demo_permission_desc_bg));

        if (isHasSimpleXCamera) {
            RelativeLayout.LayoutParams layoutParams =
                    new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
            layoutParams.topMargin = DensityUtil.getStatusBarHeight(viewGroup.getContext());
            layoutParams.leftMargin = dp10;
            layoutParams.rightMargin = dp10;
            viewGroup.addView(view, layoutParams);
        } else {
            ConstraintLayout.LayoutParams layoutParams =
                    new ConstraintLayout.LayoutParams(ConstraintLayout.LayoutParams.MATCH_PARENT, ConstraintLayout.LayoutParams.WRAP_CONTENT);
            layoutParams.topToBottom = R.id.title_bar;
            layoutParams.leftToLeft = ConstraintSet.PARENT_ID;
            layoutParams.leftMargin = dp10;
            layoutParams.rightMargin = dp10;
            viewGroup.addView(view, layoutParams);
        }
    }

    /**
     * 移除权限说明
     *
     * @param viewGroup
     */
    private static void removePermissionDescription(ViewGroup viewGroup) {
        View tagExplainView = viewGroup.findViewWithTag(TAG_EXPLAIN_VIEW);
        viewGroup.removeView(tagExplainView);
    }

    private Context getContext() {
        return mActivity;
    }

    /**
     * 自定义loading
     *
     * @return
     */
    private OnCustomLoadingListener getCustomLoadingListener() {
        return new OnCustomLoadingListener() {
            @Override
            public Dialog create(Context context) {
                return new CustomLoadingDialog(context);
            }
        };
    }

    /**
     * 处理选择结果
     *
     * @param result
     */
    private void analyticalSelectResults(ArrayList<LocalMedia> result) {
        for (LocalMedia media : result) {
            if (media.getWidth() == 0 || media.getHeight() == 0) {
                if (PictureMimeType.isHasImage(media.getMimeType())) {
                    MediaExtraInfo imageExtraInfo = MediaUtils.getImageSize(getContext(), media.getPath());
                    media.setWidth(imageExtraInfo.getWidth());
                    media.setHeight(imageExtraInfo.getHeight());
                } else if (PictureMimeType.isHasVideo(media.getMimeType())) {
                    MediaExtraInfo videoExtraInfo = MediaUtils.getVideoSize(getContext(), media.getPath());
                    media.setWidth(videoExtraInfo.getWidth());
                    media.setHeight(videoExtraInfo.getHeight());
                }
            }
            Log.i(TAG, "文件名: " + media.getFileName());
            Log.i(TAG, "是否压缩:" + media.isCompressed());
            Log.i(TAG, "压缩:" + media.getCompressPath());
            Log.i(TAG, "初始路径:" + media.getPath());
            Log.i(TAG, "绝对路径:" + media.getRealPath());
            Log.i(TAG, "是否裁剪:" + media.isCut());
            Log.i(TAG, "裁剪路径:" + media.getCutPath());
            Log.i(TAG, "是否开启原图:" + media.isOriginal());
            Log.i(TAG, "原图路径:" + media.getOriginalPath());
            Log.i(TAG, "沙盒路径:" + media.getSandboxPath());
            Log.i(TAG, "水印路径:" + media.getWatermarkPath());
            Log.i(TAG, "视频缩略图:" + media.getVideoThumbnailPath());
            Log.i(TAG, "原始宽高: " + media.getWidth() + "x" + media.getHeight());
            Log.i(TAG, "裁剪宽高: " + media.getCropImageWidth() + "x" + media.getCropImageHeight());
            Log.i(TAG, "文件大小: " + PictureFileUtils.formatAccurateUnitFileSize(media.getSize()));
            Log.i(TAG, "文件时长: " + media.getDuration());
        }
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

    ///如果是Android11以上的话就用系统相册
    @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.R)
    private boolean isAtLeast11() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.R;
    }


    @Nullable
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


