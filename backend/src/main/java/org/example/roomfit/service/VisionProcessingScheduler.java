package org.example.roomfit.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.domain.Product;
import org.example.roomfit.domain.VisionStatus;
import org.example.roomfit.repository.ImageFileRepository;
import org.example.roomfit.repository.ProductRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

/**
 * 이미지 비전 처리 재시도 스케줄러
 * 5분마다 FAILED 상태인 상품의 재처리를 시도
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class VisionProcessingScheduler {

    private final ProductRepository productRepository;
    private final ImageFileRepository imageFileRepository;
    private final ProductVisionService productVisionService;
    private final R2Service r2Service;

    /**
     * 5분마다 실패한 비전 처리 상품을 재시도
     * 최대 3회까지만 재시도, 마지막 시도 후 5분 이상 경과한 상품만
     */
    @Scheduled(fixedDelay = 300000) // 5분 = 300000ms
    @Transactional
    public void retryFailedVisionProcessing() {
        try {
            log.info("=== 실패한 이미지 비전 처리 재시도 시작 ===");

            List<Product> failedProducts = productRepository.findFailedVisionProducts();
            if (failedProducts.isEmpty()) {
                log.debug("재시도 대상 상품 없음");
                return;
            }

            log.info("재시도 대상 상품 수: {}", failedProducts.size());

            long fiveMinutesAgo = System.currentTimeMillis() - (5 * 60 * 1000);
            List<Product> retryTargets = failedProducts.stream()
                    .filter(p -> p.getVisionLastAttemptAt() == null ||
                            p.getVisionLastAttemptAt().toInstant().toEpochMilli() <= fiveMinutesAgo)
                    .toList();

            if (retryTargets.isEmpty()) {
                log.debug("재시도 대기 시간이 경과하지 않은 상품만 있음");
                return;
            }

            log.info("재시도 실행 대상 상품 수: {}", retryTargets.size());

            for (Product product : retryTargets) {
                try {
                    log.info("비전 처리 재시도 시작: productId={}, retryCount={}",
                            product.getId(), product.getVisionRetryCount());

                    org.example.roomfit.domain.ImageFile thumbnail =
                            imageFileRepository.findByProduct_IdAndOrderIndex(product.getId(), 0);

                    if (thumbnail == null) {
                        log.warn("썸네일 이미지 없음: productId={}", product.getId());
                        product.setVisionStatus(VisionStatus.FAILED.getValue());
                        product.setVisionErrorMessage("썸네일 이미지 없음");
                        productRepository.save(product);
                        continue;
                    }

                    byte[] imageBytes = r2Service.downloadFile(thumbnail.getImageUrl());
                    if (imageBytes == null || imageBytes.length == 0) {
                        log.warn("이미지 다운로드 실패: productId={}, imageUrl={}",
                                product.getId(), thumbnail.getImageUrl());
                        product.setVisionStatus(VisionStatus.FAILED.getValue());
                        product.setVisionErrorMessage("이미지 다운로드 실패");
                        productRepository.save(product);
                        continue;
                    }

                    String filename = extractFilenameFromUrl(thumbnail.getImageUrl());
                    log.info("비전 처리 재시도 중: productId={}, imageSize={}",
                            product.getId(), imageBytes.length);

                    productVisionService.processImageAsync(product.getId(), imageBytes, filename);

                } catch (Exception e) {
                    log.error("비전 처리 재시도 중 에러: productId={}, error={}",
                            product.getId(), e.getMessage(), e);

                    Product failedProduct = productRepository.findById(product.getId()).orElse(null);
                    if (failedProduct != null) {
                        failedProduct.setVisionStatus(VisionStatus.FAILED.getValue());
                        failedProduct.setVisionErrorMessage("스케줄러 재시도 중 에러: " + e.getMessage());
                        failedProduct.setVisionLastAttemptAt(OffsetDateTime.now(ZoneOffset.UTC));
                        productRepository.save(failedProduct);
                    }
                }
            }

            log.info("=== 실패한 이미지 비전 처리 재시도 종료 ===");

        } catch (Exception e) {
            log.error("실패한 이미지 비전 처리 재시도 중 예상치 못한 에러 발생", e);
        }
    }

    /**
     * URL에서 파일명 추출
     */
    private String extractFilenameFromUrl(String url) {
        if (url == null || url.isBlank()) {
            return "image.jpg";
        }

        int lastSlashIndex = url.lastIndexOf('/');
        if (lastSlashIndex >= 0 && lastSlashIndex < url.length() - 1) {
            return url.substring(lastSlashIndex + 1);
        }

        if (url.contains("?")) {
            return url.substring(url.lastIndexOf('/') + 1, url.indexOf('?'));
        }

        return url;
    }
}
