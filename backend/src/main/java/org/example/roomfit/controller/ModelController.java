package org.example.roomfit.controller;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.dto.CreateModel;
import org.example.roomfit.service.FastApiService;
import org.example.roomfit.service.ProductService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/models")
public class ModelController {
    private final ProductService productService;
    private final FastApiService fastApiService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public String createModel(@ModelAttribute CreateModel createModel) {
        log.info("3D 모델 생성 요청 접수 (비동기 처리 시작): productId={}", createModel.getProductId());

        fastApiService.request3DModelGeneration(createModel)
            .thenAccept(response -> {

                log.info("알림 전송 등 완료 콜백 처리 필요");
            })
            .exceptionally(error -> {
                log.error("처리 중 에러 발생", error);
                return null; // 예외 처리 후 반환값 무시
            });

        return "3D 모델 생성 요청이 접수되었습니다. 완료되면 알림을 보내드립니다.";
    }
}
