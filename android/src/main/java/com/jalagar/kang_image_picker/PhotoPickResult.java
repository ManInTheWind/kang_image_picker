package com.jalagar.kang_image_picker;

import java.util.HashMap;
import java.util.Map;

public class PhotoPickResult {
    private String id;
    private String path;
    private Integer width;
    private Integer height;
    private String filename;
    private String mimeType;

    private Long size;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

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

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public Map<String, Object> toMap() {
        return new HashMap<String, Object>() {
            {
                put("id", id);
                put("path", path);
                put("width", width);
                put("height", height);
                put("filename", filename);
                put("mimeType", mimeType);
                put("size", size);
            }
        };
    }
}
