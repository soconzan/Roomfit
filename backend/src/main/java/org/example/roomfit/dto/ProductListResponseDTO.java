package org.example.roomfit.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;

@AllArgsConstructor
@Getter
@Setter
public class ProductListResponseDTO {
    private Long productId;
    private String productName;
    private Long productPrice;
    private OffsetDateTime createdAt;
    private String thumbnailUrl;
    private String categoryName;
}
