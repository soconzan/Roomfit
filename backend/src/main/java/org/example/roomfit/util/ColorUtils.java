package org.example.roomfit.util;

import java.util.List;

public class ColorUtils {

    public static boolean isSimilarColor(List<Float> color1, List<Float> color2) {
        // 여기에서 들어온 색이 비슷한 색인지 판단한다.
        // HSV 색상을 받아서 두 색이 비슷한 색인지 또는 반대되는 색인지 판단하고 비슷한 색이면 반대되는 색을 추천하고 반대되는 색이면 비슷한 색을 추천하는 로직을 구현
        // 예시: HSV 색상에서 H(색상) 값이 0~360, S(채도) 값이 0~1, V(명도) 값이 0~1 범위라고 가정
        float hue1 = color1.get(0);
        float saturation1 = color1.get(1);
        float value1 = color1.get(2);

        float hue2 = color2.get(0);
        float saturation2 = color2.get(1);
        float value2 = color2.get(2);

        // 색상 차이 계산 (예시로 단순한 차이 계산)
        float hueDifference = Math.abs(hue1 - hue2);
        float saturationDifference = Math.abs(saturation1 - saturation2);
        float valueDifference = Math.abs(value1 - value2);

        // 색상 차이가 일정 기준 이하이면 비슷한 색으로 판단 (예시로 30도 이하)
        if (hueDifference < 30 && saturationDifference < 0.2 && valueDifference < 0.2) {
            return true; // 비슷한 색
        } else {
            return false; // 반대되는 색
        }
    }
}
