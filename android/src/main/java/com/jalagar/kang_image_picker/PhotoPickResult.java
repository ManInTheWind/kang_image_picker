package com.jalagar.kang_image_picker;

import java.util.HashMap;
import java.util.Map;

public class PhotoPickResult {
    private String path;
    private Integer width;
    private Integer height;
    private String filename;
    private String mimeType;

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Integer getWidth() {
        return width;
    }

    public void setWidth(Integer width) {
        this.width = width;
    }

    public Integer getHeight() {
        return height;
    }

    public void setHeight(Integer height) {
        this.height = height;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public Map<String, Object> toMap() {
        return new HashMap<String, Object>() {
            {
                put("path", path);
                put("width", width);
                put("height", height);
                put("filename", filename);
                put("mimeType", mimeType);
            }
        };
    }
}
