package org.example.roomfit.dto;

import org.springframework.web.multipart.MultipartFile;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@ToString
public class CreateProduct {
    private UUID userId;          // html name="user_id" (서버에서 직접 조회하는 방식으로 바꾸지 않으면 그대로 사용)
    private Long categoryId;        // html name="category_id"
    private String productName;      // html name="product_name"
    private Long productPrice;     // html name="product_price"
    private String description;     // html name="description"
    private Float productWidth;      // html name="product_width"
    private Float productDepth;      // html name="product_depth"
    private Float productHeight;     // html name="product_height" (HTML 오타 교정됨)
    private String productMaterial;  // html name="product_material"
    private List<MultipartFile> images; // html name="images" (여러 파일 업로드를 위한 List<MultipartFile>)
    private MultipartFile frontImage;
    private MultipartFile leftImage;
    private MultipartFile rightImage;
    private MultipartFile backImage;
}
