package org.example.roomfit.dto;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

@Getter
@Setter
public class RecommendProductDTO {
    private Long category;
    private MultipartFile image;
    private float width;
    private float height;
    private float depth;

    @Override
    public String toString() {
        return "RecommendProductDTO{" +
            "category='" + category + '\'' +
            ", image=" + (image != null ? image.getOriginalFilename() : "null") +
            ", width=" + width +
            ", height=" + height +
            ", depth=" + depth +
            '}';
    }
}
