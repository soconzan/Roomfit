package org.example.roomfit.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@AllArgsConstructor
@Getter
@Setter
public class ProductModelResponseDTO {
    private Long productId;
    private String modelUrl;
}
