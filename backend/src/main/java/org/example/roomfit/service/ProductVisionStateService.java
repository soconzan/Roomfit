package org.example.roomfit.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.domain.Product;
import org.example.roomfit.domain.VisionStatus;
import org.example.roomfit.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductVisionStateService {

    private final ProductRepository productRepository;

    @Transactional
    public void markFailed(Long productId, String message) {
        Product product = productRepository.findById(productId).orElse(null);
        if (product == null) {
            return;
        }
        product.setVisionStatus(VisionStatus.FAILED.getValue());
        product.setVisionRetryCount((product.getVisionRetryCount() != null ? product.getVisionRetryCount() : 0) + 1);
        product.setVisionErrorMessage(message);
        product.setVisionLastAttemptAt(OffsetDateTime.now(ZoneOffset.UTC));
        productRepository.save(product);
    }
}
