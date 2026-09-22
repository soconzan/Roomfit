package org.example.roomfit.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter
public class ProductDetailResponseDTO {
    private Long productId;
    private UUID userId;
    private String nickname;
    private String productName;
    private Long categoryId;
    private String categoryName;
    private Long productPrice;
    private String description;
    private Double productWidth;
    private Double productDepth;
    private Double productHeight;
    private String material;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
    private List<String> imageUrls;
    private String userImagUrl;
}
