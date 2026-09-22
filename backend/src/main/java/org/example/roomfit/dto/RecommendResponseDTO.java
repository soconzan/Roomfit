package org.example.roomfit.dto;

import aQute.bnd.annotation.metatype.Meta;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RecommendResponseDTO {
    private Long productId;
    private String productName;
    private Long productPrice;
    private Float productWidth;
    private Float productDepth;
    private Float productHeight;
    private String imageUrl;
    private String modelUrl;
}
