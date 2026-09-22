package org.example.roomfit.service;

import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import org.example.roomfit.dto.RecommendProductDTO;
import org.example.roomfit.dto.RecommendResponseDTO;
import org.example.roomfit.repository.ProductRepository;
import org.example.roomfit.util.ColorUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import lombok.AllArgsConstructor;

@AllArgsConstructor
@Service
public class RecommendService {
    private static final Logger log = LoggerFactory.getLogger(RecommendService.class);
    private final GroundedSAMClient groundedSAMClient;
    private final VisionServiceClient visionServiceClient;
    private final ProductRepository productRepository;

    public List<RecommendResponseDTO> recommendProducts(RecommendProductDTO recommendProduct) throws Exception {
        // 먼저 업로드된 사이즈 정보에 맞는 제품이 있는지 확인한다.
        int productCount = productRepository.findProductsBySize(
                recommendProduct.getWidth(),
                recommendProduct.getDepth(),
                recommendProduct.getHeight()
        );
        if (productCount == 0) {
            log.info("No products found matching the specified size.");
            return Collections.emptyList();
        }

        byte[] imageBytes = recommendProduct.getImage().getBytes();
        String filename = recommendProduct.getImage().getOriginalFilename();

        CompletableFuture<Map<String, Object>> detectedObjectFuture = CompletableFuture.supplyAsync(() ->
                groundedSAMClient.segmentImage(imageBytes, filename, null) // 텍스트 프롬프트는 null로 전달하여 모든 객체 감지
        );
        CompletableFuture<List<List<Float>>> dominantColorsFuture = CompletableFuture.supplyAsync(() ->
                visionServiceClient.extractDominantColors(imageBytes, filename)
        );

        CompletableFuture.allOf(detectedObjectFuture, dominantColorsFuture).join();

        Map<String, Object> detectedObject = detectedObjectFuture.join();
        List<List<Float>> dominantColors = dominantColorsFuture.join();

        log.info("Dominant colors extracted: {}", dominantColors.size());

        // 2. 감지된 객체 이미지를 base64에서 바이트 배열로 변환 후 각 객체에 대한 임베딩 생성
        List<Map<String, List<Float>>> embeddings = segmentAndEmbedDetectedImage(detectedObject);

        // 3. 여러 객체의 임베딩을 평균하여 하나의 임베딩으로 혼합
        List<Float> mixedEmbedding = new ArrayList<>();

        for (Map<String, List<Float>> set : embeddings) {
            set.keySet().forEach(key -> {
                log.info("Object: {}", key);
                List<Float> embedding = set.get(key);
                for (int i = 0; i < embedding.size(); i++) {
                    if (mixedEmbedding.size() <= i) {
                        mixedEmbedding.add(embedding.get(i));
                    } else {
                        mixedEmbedding.set(i, mixedEmbedding.get(i) + embedding.get(i));
                    }
                }
            });
        }
        for (int i = 0; i < mixedEmbedding.size(); i++) {
            mixedEmbedding.set(i, mixedEmbedding.get(i) / embeddings.size());
        }

        normalizeEmbedding(mixedEmbedding);

        List<Float> recommendedColor = null;
        if (ColorUtils.isSimilarColor(dominantColors.get(0), dominantColors.get(1))){
            log.info("Colors are similar, recommending opposite color products");
            // 비슷한 색상인 경우 반대되는 색상으로 추천
            recommendedColor = new ArrayList<Float>();
            recommendedColor.add((dominantColors.get(0).get(0) + 180) % 360); // H 값 반전
            recommendedColor.add(dominantColors.get(0).get(1)); // S 값 유지
            recommendedColor.add(dominantColors.get(0).get(2)); // V 값 유지
        } else {
            log.info("Colors are different, recommending similar color products");
            // 반대되는 색상인 경우 비슷한 색상으로 추천
            recommendedColor = dominantColors.get(0); // 첫 번째 색상 유지
        }
        log.info("Recommended color (HSV): {}", recommendedColor);

        // 5. 정규화된 임베딩을 사용하여 유사한 제품 검색
        List<Object[]> results;
        if (recommendProduct.getCategory() != null) {
            results = productRepository.findSimilarProductsWithColor(mixedEmbedding.toString(), 10, recommendProduct.getWidth(), recommendProduct.getDepth(), recommendProduct.getHeight(), recommendProduct.getCategory(), recommendedColor.toString());
        } else {
            results = productRepository.findSimilarProductsWithColor(mixedEmbedding.toString(), 10, recommendProduct.getWidth(), recommendProduct.getDepth(), recommendProduct.getHeight(), recommendedColor.toString());
        }

        List<RecommendResponseDTO> products = results.stream()
                .map(p -> new RecommendResponseDTO(
                        ((Number) p[0]).longValue(),
                        (String) p[1],
                        ((Number) p[2]).longValue(),
                        ((Number) p[3]).floatValue(),
                        ((Number) p[4]).floatValue(),
                        ((Number) p[5]).floatValue(),
                        (String) p[6],
                        (String) p[7]
                )).collect(Collectors.toList());

        return products;
    }

    private List<Map<String, List<Float>>> segmentAndEmbedDetectedImage(Map<String, Object> detectedObject) {
        List<Map<String, List<Float>>> embeddings = new ArrayList<>();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> detectedImage = (List<Map<String, Object>>) detectedObject.get("objects");

        log.info("Detected objects: {}", detectedImage.size());

        // 2. 감지된 객체 이미지를 base64에서 바이트 배열로 변환 후 각 객체에 대한 임베딩 생성
        detectedImage.forEach(entry -> {
            String objectName = entry.get("tag") + ".png";
            String base64Image = (String) entry.get("image");
            byte[] imageBytes = Base64.getDecoder().decode(base64Image);

            List<Float> embedding = visionServiceClient.getEmbeddingFromFastApi(imageBytes, objectName);
            embeddings.add(Map.of((String) entry.get("tag"), embedding));
        });

        return embeddings;
    }

    private void normalizeEmbedding(List<Float> embedding) {
        double norm = Math.sqrt(embedding.stream().map(x -> x * x).reduce(0.0f, Float::sum));
        if (norm > 0) {
            for (int i = 0; i < embedding.size(); i++) {
                embedding.set(i, embedding.get(i) / (float) norm);
            }
        }
    }
}
