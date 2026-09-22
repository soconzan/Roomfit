package org.example.roomfit.dto;

import org.springframework.web.multipart.MultipartFile;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Setter
@Getter
@ToString
public class ProductSearchDTO {
    private MultipartFile file;
}
// 지금 안 씁니다.