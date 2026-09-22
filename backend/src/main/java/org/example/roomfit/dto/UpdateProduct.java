package org.example.roomfit.dto;

import java.util.UUID;

import org.springframework.web.multipart.MultipartFile;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateProduct {
    private UUID userId;          // html name="user_id" (서버에서 직접 조회하는 방식으로 바꾸지 않으면 그대로 사용)
    private Long productId;        // html name="product_id"
    private Long categoryId;        // html name="category_id"
    private String productName;      // html name="product_name"
    private Long productPrice;     // html name="product_price"
    private String description;     // html name="description"
    private float productWidth;      // html name="product_width"
    private float productDepth;      // html name="product_depth"
    private float productHeight;     // html name="product_height" (HTML 오타 교정됨)
    private String productMaterial;  // html name="product_material"
    private MultipartFile frontImage;
    private MultipartFile leftImage;
    private MultipartFile rightImage;
    private MultipartFile backImage;
}