package com.jalagar.kang_image_picker;

import androidx.annotation.NonNull;

import com.luck.picture.lib.config.SelectMimeType;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class FlutterPickerConfiguration {

    /**
     * 选择库中可用的媒体类型。默认为.photo
     * {@link SelectMimeType}
     */
    private Integer mediaType;

    ///是否开启裁剪，以及裁剪比例，默认.none,可Null
    private Double cropRatio;

    ///主题颜色,可Null
    private String tintColor;

    ///选择数量
    private Integer maxNumberOfItems =1;

    ///定义记录视频的时间限制。默认为30秒,可Null
    private Integer videoRecordingTimeLimit = 30;

    ///视频长度。默认60秒,可Null
    private Integer trimmerMaxDuration = 30;

    public static FlutterPickerConfiguration fromObject(Object obj) throws JSONException {
        if (!(obj instanceof Map)) {
            return defaultConfiguration();
        }
        JSONObject jsonObject = new JSONObject((Map<?, ?>) obj);
        Map<String, Object> map = new HashMap<>();
        Iterator<String> iterator = jsonObject.keys();
        while (iterator.hasNext()) {
            String key = iterator.next();
            Object value = jsonObject.get(key);
            map.put(key, value);
        }
        FlutterPickerConfiguration configuration = new FlutterPickerConfiguration();
        Integer mediaType = ((Integer) map.get("mediaType"));
        if (mediaType != null) {
            switch (mediaType) {
                case 0:
                    configuration.setMediaType(SelectMimeType.ofImage());
                    break;
                case 1:
                    configuration.setMediaType(SelectMimeType.ofVideo());
                    break;
                case 2:
                default:
                    configuration.setMediaType(SelectMimeType.ofAll());
                    break;
            }
        }
        System.out.println("map:" + map);
        configuration.setCropRatio(((Double) map.get("cropRatio")));
        configuration.setTintColor(((String) map.get("tintColor")));
        configuration.setMaxNumberOfItems(((Integer) map.get("maxNumberOfItems")));
        if (map.get("videoRecordingTimeLimit") != null) {
            configuration.setVideoRecordingTimeLimit(((Integer) map.get("videoRecordingTimeLimit")));
        }
        if (map.get("trimmerMaxDuration") != null) {
            configuration.setTrimmerMaxDuration(((Integer) map.get("trimmerMaxDuration")));
        }
        return configuration;
    }

    public static FlutterPickerConfiguration defaultConfiguration() {
        FlutterPickerConfiguration configuration = new FlutterPickerConfiguration();
        configuration.setMediaType(SelectMimeType.ofAll());
        configuration.setMaxNumberOfItems(1);
        configuration.setVideoRecordingTimeLimit(20);
        configuration.setTrimmerMaxDuration(20);
        return configuration;
    }


//    public static FlutterPickerConfiguration fromObject(Object obj) throws IllegalAccessException {
//        Map<String, Object> map = new HashMap<>();
//        Class<?> clazz = obj.getClass();
//        for (Field field : clazz.getDeclaredFields()) {
//            field.setAccessible(true);
//            String fieldName = field.getName();
//            Object fieldValue = field.get(obj);
//            map.put(fieldName, fieldValue);
//        }
//        FlutterPickerConfiguration configuration = new FlutterPickerConfiguration();
//        Integer mediaType = ((Integer) map.get("mediaType"));
//        if (mediaType != null) {
//            switch (mediaType) {
//                case 0:
//                    configuration.setMediaType(SelectMimeType.ofImage());
//                    break;
//                case 1:
//                    configuration.setMediaType(SelectMimeType.ofVideo());
//                    break;
//                case 2:
//                default:
//                    configuration.setMediaType(SelectMimeType.ofAll());
//                    break;
//            }
//        }
//        configuration.setCropRatio(((Double) map.get("cropRatio")));
//        configuration.setTintColor(((String) map.get("tintColor")));
//        configuration.setMaxNumberOfItems(((Integer) map.get("maxNumberOfItems")));
//        configuration.setVideoRecordingTimeLimit(((Integer) map.get("videoRecordingTimeLimit")));
//        configuration.setTrimmerMaxDuration(((Integer) map.get("trimmerMaxDuration")));
//        return configuration;
//    }


    public void setMediaType(Integer mediaType) {
        this.mediaType = mediaType;
    }

    public void setCropRatio(Double cropRatio) {
        this.cropRatio = cropRatio;
    }

    public void setTintColor(String tintColor) {
        this.tintColor = tintColor;
    }

    public void setMaxNumberOfItems(Integer maxNumberOfItems) {
        this.maxNumberOfItems = maxNumberOfItems;
    }

    public void setVideoRecordingTimeLimit(Integer videoRecordingTimeLimit) {
        this.videoRecordingTimeLimit = videoRecordingTimeLimit;
    }

    public void setTrimmerMaxDuration(Integer trimmerMaxDuration) {
        this.trimmerMaxDuration = trimmerMaxDuration;
    }

    public Integer getMediaType() {
        return mediaType;
    }

    public Double getCropRatio() {
        return cropRatio;
    }

    public String getTintColor() {
        return tintColor;
    }

    public Integer getMaxNumberOfItems() {
        return maxNumberOfItems;
    }

    public Integer getVideoRecordingTimeLimit() {
        return videoRecordingTimeLimit;
    }

    public Integer getTrimmerMaxDuration() {
        return trimmerMaxDuration;
    }

    @NonNull
    @Override
    public String toString() {
        return "FlutterPickerConfiguration{" +
                "mediaType=" + mediaType +
                ", cropRatio=" + cropRatio +
                ", tintColor='" + tintColor + '\'' +
                ", maxNumberOfItems=" + maxNumberOfItems +
                ", videoRecordingTimeLimit=" + videoRecordingTimeLimit +
                ", trimmerMaxDuration=" + trimmerMaxDuration +
                '}';
    }
}
