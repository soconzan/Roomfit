package org.example.roomfit.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.domain.Product;
import org.example.roomfit.domain.VisionStatus;
import org.example.roomfit.repository.ProductRepository;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductVisionService {

    private final ProductRepository productRepository;
    private final VisionServiceClient visionServiceClient;
    private final ProductVisionStateService productVisionStateService;

    @Async
    public void processImageAsync(Long productId, byte[] thumbnailBytes, String filename) {
        try {
            log.info("이미지 비전 처리 시작: productId={}", productId);

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new NoSuchElementException("상품을 찾을 수 없습니다."));

            product.setVisionStatus(VisionStatus.PROCESSING.getValue());
            product.setVisionLastAttemptAt(OffsetDateTime.now(ZoneOffset.UTC));
            productRepository.save(product);

            ByteArrayResource resource = new ByteArrayResource(thumbnailBytes) {
                @Override
                public String getFilename() {
                    return filename;
                }
            };

            byte[] nobgImage = visionServiceClient.removeBackgroundFromFastApi(resource);
            String embedding = visionServiceClient.getEmbeddingFromFastApi(nobgImage, filename).toString();
            List<List<Float>> colorVectors = visionServiceClient.extractDominantColors(nobgImage, filename);

            product.setImageEmbedding(embedding);
            if (colorVectors != null && !colorVectors.isEmpty()) {
                product.setColorVector1(colorVectors.get(0).toString());
                if (colorVectors.size() > 1) product.setColorVector2(colorVectors.get(1).toString());
                if (colorVectors.size() > 2) product.setColorVector3(colorVectors.get(2).toString());
            }

            product.setVisionStatus(VisionStatus.DONE.getValue());
            product.setVisionErrorMessage(null);
            productRepository.save(product);
            log.info("이미지 비전 처리 완료: productId={}", productId);
        } catch (Exception e) {
            log.error("이미지 비전 처리 실패: productId={}, error={}", productId, e.getMessage(), e);
            productVisionStateService.markFailed(productId, e.getMessage());
        }
    }
}
