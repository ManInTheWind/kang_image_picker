package com.jalagar.kang_image_picker;

import java.util.HashMap;
import java.util.Map;

public class VideoPickResult {
    private String videoPath;
    private Double duration;
    private String thumbnailPath;
    private int thumbnailWidth;
    private int thumbnailHeight;

    public String getVideoPath() {
        return videoPath;
    }

    public void setVideoPath(String videoPath) {
        this.videoPath = videoPath;
    }

    public Double getDuration() {
        return duration;
    }

    public void setDuration(Double duration) {
        this.duration = duration;
    }

    public String getThumbnailPath() {
        return thumbnailPath;
    }

    public void setThumbnailPath(String thumbnailPath) {
        this.thumbnailPath = thumbnailPath;
    }

    public int getThumbnailWidth() {
        return thumbnailWidth;
    }

    public void setThumbnailWidth(int thumbnailWidth) {
        this.thumbnailWidth = thumbnailWidth;
    }

    public int getThumbnailHeight() {
        return thumbnailHeight;
    }

    public void setThumbnailHeight(int thumbnailHeight) {
        this.thumbnailHeight = thumbnailHeight;
    }

    public Map<String, Object> toMap() {
        return new HashMap<String, Object>() {
            {
                put("videoPath", videoPath);
                put("thumbnailPath", thumbnailPath);
                put("thumbnailWidth", thumbnailWidth);
                put("thumbnailHeight", videoPath);
                put("duration", duration);
            }
        };
    }
}
