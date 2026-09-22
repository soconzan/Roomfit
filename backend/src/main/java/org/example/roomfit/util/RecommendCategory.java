package org.example.roomfit.util;

import java.util.List;

public class RecommendCategory {

    private static final List<String> DETECT_CATEGORY_LIST = List.of(
            "chair", "table", "sofa", "bed", "bookshelf",
            "cabinet", "furniture"
    );

    private static final List<String> ALL_CATEGORY_LIST = List.of(
            "chair", "table", "sofa", "bed", "shelf",
            "bookshelf", "cabinet", "closet", "desk", "console",
            "furniture", "dresser"
    );

    private static final String DETECT_CATEGORY = String.join(" . ", DETECT_CATEGORY_LIST);

    public static String getDetectCategory() {
        return DETECT_CATEGORY;
    }

    public static List<String> getAllCategory() {
        return ALL_CATEGORY_LIST;
    }

    public static boolean isDirectCompareCategory(String category) {
        // category는 "chair table"같은 형태로 들어올 수 있음
        // 따라서 category를 공백으로 분리하여 각각의 요소가 DIRECT_COMPARE_FURNITURE_CATEGORIES에 포함되는지 확인
        String[] categories = category.split("\\s+");
        for (String cat : categories) {
            if (DETECT_CATEGORY_LIST.contains(cat)) {
                return true;
            }
        }
        return false;
    }
}
