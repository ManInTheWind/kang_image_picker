package com.jalagar.kang_image_picker;

import androidx.annotation.NonNull;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;

public class CropRatio {
    private int x;
    private int y;

    public CropRatio() {

    }

    public CropRatio(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public static CropRatio fromValue(double ratio) {
        CropRatio cropRatio = new CropRatio();
//        if (ratio <= 0) {
//            cropRatio.setX(1);
//            cropRatio.setY(1);
//            return cropRatio;
//        }
        int width;
        int height;
        double roundRatio = Math.floor(ratio * 100) / 100.0;

        Map<Double, int[]> ratioMap = new HashMap<>();
        ratioMap.put(1.00, new int[]{1, 1});
        ratioMap.put(0.66, new int[]{2, 3});
        ratioMap.put(1.50, new int[]{3, 2});
        ratioMap.put(0.75, new int[]{3, 4});
        ratioMap.put(1.33, new int[]{4, 3});
        ratioMap.put(0.60, new int[]{3, 5});
        ratioMap.put(1.66, new int[]{5, 3});
        ratioMap.put(1.77, new int[]{16, 9});
        ratioMap.put(0.56, new int[]{9, 16});
        ratioMap.put(0.80, new int[]{4, 5});
        ratioMap.put(1.25, new int[]{5, 4});
        ratioMap.put(0.71, new int[]{5, 7});
        ratioMap.put(1.40, new int[]{7, 5});
        int[] size = ratioMap.get(roundRatio);
        if (size != null) {
            width = size[0];
            height = size[1];
        } else {
//            double gcd = gcd(16 * ratio, 9);
//            width = (int) Math.round(16 * ratio / gcd);
//            height = (int) Math.round(9 / gcd);
            width = -1;
            height = -1;
        }
        cropRatio.setX(width);
        cropRatio.setY(height);
        return cropRatio;
    }

    private static double gcd(double a, double b) {
        if (b == 0) {
            return a;
        } else {
            return gcd(b, a % b);
        }
    }

    public int getX() {
        return x;
    }

    public void setX(int x) {
        this.x = x;
    }

    public int getY() {
        return y;
    }

    public void setY(int y) {
        this.y = y;
    }

    @NonNull
    @Override
    public String toString() {
        return "CropRatio{" +
                "x=" + x +
                ", y=" + y +
                '}';
    }
}
