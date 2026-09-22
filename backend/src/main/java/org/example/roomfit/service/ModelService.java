package org.example.roomfit.service;

import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.example.roomfit.domain.Product;
import org.example.roomfit.dto.CreateModel;
import org.example.roomfit.repository.CategoryRepository;
import org.example.roomfit.repository.ProductRepository;
import org.example.roomfit.repository.UserRepository;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ModelService {
    private final ProductRepository productRepository;
    private final FastApiService fastApiService;
    private final FcmService fcmService;
    private final VisionServiceClient visionServiceClient;
    private final UserRepository userRepository;
    private final GroundedSAMClient groundedSAMClient;
    private final R2Service r2Service;
    private final CategoryRepository categoryRepository;

    // private final String BLIP_PROMPT = "Please identify the category of the furniture located at the center of the image and reply with a single English word only (for example: sofa, chair, table). Output exactly one word in English and nothing else.";
    // private final int BLIP_MAX_LENGTH = 12;
    @Async
    public void processModel(byte[] front, byte[] left, byte[] right, byte[] back, Long productId, Product savedProduct) {
        // 모델 리소스 처리 로직 구현
        // 예: 모델 리소스 저장, 검증, 변환 etc.
        
        // 3D 모델 비동기 생성 요청
        if (front != null || left != null || right != null || back != null) {
            CreateModel createModel = buildCreateModel(front, left, right, back, productId);

            if (savedProduct == null) {
                savedProduct = productRepository.findById(productId).orElse(null);
                if (savedProduct == null) {
                    log.error("상품을 찾을 수 없습니다. productId={}", productId);
                    throw new IllegalStateException("상품을 찾을 수 없습니다. productId=" + productId);
                }
            }

            saveImagesR2(createModel.getImageFront(), createModel.getImageLeft(), createModel.getImageRight(), createModel.getImageBack(), productId, savedProduct);
            UUID userId = savedProduct.getUser().getUserId();
            String productName = savedProduct.getProductName();

            log.info("3D 모델 생성 비동기 처리 시작");
            fastApiService.request3DModelGeneration(createModel)
                    .thenAccept(modelUrl -> {
                        productRepository.findById(productId).ifPresent(product -> {
                            product.setModelUrl(modelUrl);
                            productRepository.save(product);
                            log.info("3D 모델 URL DB 반영 완료: {}", modelUrl);
                        });
                        userRepository.findById(userId).ifPresent(user -> {
                            String username = user.getUsername();
                            String title = "3D 모델 생성 완료";
                            String message = "상품 '" + cutString(productName, 15) + "'의 3D 모델이 생성되었습니다.";
                            log.info("FCM 알림 전송 준비: username={}, title={}, message={}", username, title, message);
                            fcmService.sendFcmNotification(username, title, message);
                        });
                    })
                    .exceptionally(error -> {
                        log.error("3D 모델 비동기 생성 및 업데이트 중 에러 발생", error);
                        return null;
                    });

        }
    }

    private CreateModel buildCreateModel(byte[] front, byte[] left, byte[] right, byte[] back, Long productId) {
        CreateModel createModel = new CreateModel();
        if(front == null) {
            log.warn("front 이미지가 제공되지 않았습니다. 모델 생성에 front 이미지는 필수입니다.");
            throw new IllegalArgumentException("front 이미지는 필수입니다.");
        }

        // CLIP으로 카테고리 감지 후 Grounded SAM으로 객체 세분화
        String detectedCategory = categoryRepository.findSimilarCategory(visionServiceClient.getEmbeddingFromFastApi(front, "front.png").toString()).getCategoryName();
        log.info("Detected category: {}", detectedCategory);
        front = fromBase64ToByteArray((String) ((List<Map<String, Object>>) groundedSAMClient.segmentImage(front, "front.png", detectedCategory).get("objects")).get(0).get("image"));
        if(left != null) {
            left = fromBase64ToByteArray((String) ((List<Map<String, Object>>) groundedSAMClient.segmentImage(left, "left.png", detectedCategory).get("objects")).get(0).get("image"));
        }
        if(right != null) {
            right = fromBase64ToByteArray((String) ((List<Map<String, Object>>) groundedSAMClient.segmentImage(right, "right.png", detectedCategory).get("objects")).get(0).get("image"));
        }
        if(back != null) {
            back = fromBase64ToByteArray((String) ((List<Map<String, Object>>) groundedSAMClient.segmentImage(back, "back.png", detectedCategory).get("objects")).get(0).get("image"));
        }

        createModel.setProductId(productId);
        createModel.setImageFront(front);
        createModel.setImageLeft(left);
        createModel.setImageRight(right);
        createModel.setImageBack(back);
        return createModel;
    }

    private void saveImagesR2(byte[] front, byte[] left, byte[] right, byte[] back, Long productId, Product savedProduct) {
        // 이미지 저장 로직 구현 (예: S3 업로드, DB 저장 등)
        // 예시에서는 단순히 로그로 저장된 이미지를 확인
        log.info("Saving images for productId={}", productId);
        String frontUrl = null, leftUrl = null, rightUrl = null, backUrl = null;
        if (front != null) {
            log.info("Front image size: {} bytes", front.length);
            frontUrl = r2Service.uploadFile(front, "products/" + productId, ".png", "image/png");
            log.info("Front image uploaded to R2: {}", frontUrl);
        }
        if (left != null) {
            log.info("Left image size: {} bytes", left.length);
            leftUrl = r2Service.uploadFile(left, "products/" + productId, ".png", "image/png");
            log.info("Left image uploaded to R2: {}", leftUrl);
        }
        if (right != null) {
            log.info("Right image size: {} bytes", right.length);
            rightUrl = r2Service.uploadFile(right, "products/" + productId, ".png", "image/png");
            log.info("Right image uploaded to R2: {}", rightUrl);
        }
        if (back != null) {
            log.info("Back image size: {} bytes", back.length);
            backUrl = r2Service.uploadFile(back, "products/" + productId, ".png", "image/png");
            log.info("Back image uploaded to R2: {}", backUrl);
        }
        savedProduct.setProductImageFrontUrl(frontUrl);
        savedProduct.setProductImageLeftUrl(leftUrl);
        savedProduct.setProductImageRightUrl(rightUrl);
        savedProduct.setProductImageBackUrl(backUrl);
    }

    private String cutString(String input, int maxLength) {
        if (input == null) return null;
        return input.length() <= maxLength ? input : input.substring(0, maxLength) + "...";
    }

    private byte[] fromBase64ToByteArray(String base64) {
        return Base64.getDecoder().decode(base64);
    }
}