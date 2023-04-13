package com.jalagar.kang_image_picker;

import java.util.HashMap;
import java.util.Map;

public class VideoPickResult {
    private String videoPath;

    private String videoFilename;
    private Double duration;

    private String thumbnailFilename;
    private String thumbnailPath;
    private int thumbnailWidth;
    private int thumbnailHeight;

    private Long size;

    public String getVideoPath() {
        return videoPath;
    }

    public void setVideoPath(String videoPath) {
        this.videoPath = videoPath;
    }

    public String getVideoFilename() {
        return videoFilename;
    }

    public void setVideoFilename(String videoFilename) {
        this.videoFilename = videoFilename;
    }

    public Double getDuration() {
        return duration;
    }

    public void setDuration(Double duration) {
        this.duration = duration;
    }

    public String getThumbnailFilename() {
        return thumbnailFilename;
    }

    public void setThumbnailFilename(String thumbnailFilename) {
        this.thumbnailFilename = thumbnailFilename;
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

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public Map<String, Object> toMap() {
        return new HashMap<String, Object>() {
            {
                put("videoPath", videoPath);
                put("videoFilename", videoFilename);
                put("thumbnailFilename", thumbnailFilename);
                put("thumbnailPath", thumbnailPath);
                put("thumbnailWidth", thumbnailWidth);
                put("thumbnailHeight", thumbnailHeight);
                put("duration", duration);
                put("size", size);
            }
        };
    }
}
