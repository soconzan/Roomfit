package org.example.roomfit.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter
public class ProductARResponseDTO {
    private Long productId;
    private String productName;
    private Long productPrice;
    private String imageUrl;
    private String modelUrl;
}
