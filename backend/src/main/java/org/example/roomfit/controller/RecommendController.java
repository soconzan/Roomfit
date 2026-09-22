package org.example.roomfit.controller;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.domain.Product;
import org.example.roomfit.dto.RecommendProductDTO;
import org.example.roomfit.dto.RecommendResponseDTO;
import org.example.roomfit.response.ApiResponse;
import org.example.roomfit.service.RecommendService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recommend")
@AllArgsConstructor
@Slf4j
public class RecommendController {

    private final RecommendService recommendService;

    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> healthCheck() {
        log.info("Health check endpoint called");
        return ResponseEntity.ok(new ApiResponse<>(true, "Recommendation service is running", "OK"));
    }

    @PostMapping(value = "", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<List<RecommendResponseDTO>>> recommendProducts(@ModelAttribute RecommendProductDTO recommendProduct) {
        log.info("recommendProducts endpoint called");
        try {
            log.info("Received recommendation request: {}", recommendProduct.toString()); // 시스템 로그(콘솔)에 수신된 데이터 출력
            return ResponseEntity.ok(new ApiResponse<>(true,
                    "Received recommendation request: " + recommendProduct.toString(),
                    recommendService.recommendProducts(recommendProduct)));
        } catch (Exception e) {
            e.printStackTrace(); // 시스템 로그(콘솔)에 에러 스택 트레이스 강제 출력
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(false, "상품 추천 실패: " + e.getMessage(), null));
        }
    }
}
