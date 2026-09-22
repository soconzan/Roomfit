package org.example.roomfit.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@AllArgsConstructor
@Getter
@Setter
public class ProductListPageDTO {
    private List<ProductListResponseDTO> product;
    private Long nextCursor;
    private boolean hasNext;
}
