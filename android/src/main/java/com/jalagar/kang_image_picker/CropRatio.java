package com.jalagar.kang_image_picker;

public class CropRatio {
    private int x;
    private int y;

    public static CropRatio fromValue(double ratio) {
        CropRatio cropRatio = new CropRatio();
        if (ratio <= 0){
            cropRatio.setX(1);
            cropRatio.setY(1);
            return cropRatio;
        }
        int width = 16;
        int height = 9;
        if (ratio == 1) {
            width = 1;
            height = 1;
        } else if (ratio == 0.75) {
            width = 4;
            height = 3;
        } else if (ratio == 1.33) {
            width = 3;
            height = 4;
        } else if (ratio == 1.77) {
            width = 9;
            height = 16;
        } else {
            double gcd = gcd(16 * ratio, 9);
            width = (int) Math.round(16 * ratio / gcd);
            height = (int) Math.round(9 / gcd);
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
}
