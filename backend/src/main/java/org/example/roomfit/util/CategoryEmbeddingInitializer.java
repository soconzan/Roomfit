package org.example.roomfit.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.example.roomfit.domain.Category;
import org.example.roomfit.repository.CategoryRepository;
import org.example.roomfit.service.VisionServiceClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import lombok.extern.slf4j.Slf4j;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/initialize")
@RequiredArgsConstructor
@Slf4j
public class CategoryEmbeddingInitializer {

    private final CategoryRepository categoryRepository;
    private final VisionServiceClient visionServiceClient;

    @GetMapping("/initialize-category-embeddings")
    public String initializeCategoryEmbeddings() {

        log.info("카테고리 임베딩 초기화 시작");
        Map<String,String> categories = new HashMap<>(){
            {
                put("a photo of a tv stand", "거실장·TV장");
                put("a photo of a tv cabinet", "거실장·TV장");
                put("a photo of a media console", "거실장·TV장");
                put("a photo of a entertainment center", "거실장·TV장");
                put("a photo of a bed", "침대·매트리스");
                put("a photo of a mattress", "침대·매트리스");
                put("a photo of a desk", "테이블·식탁·책상");
                put("a photo of a table", "테이블·식탁·책상");
                put("a photo of a sofa", "소파");
                put("a photo of a couch", "소파");
                put("a photo of a dresser", "서랍·수납장");
                put("a photo of a shelf", "선반");
                put("a photo of a bookshelf", "진열장·책장");
                put("a photo of a cabinet", "진열장·책장");
                put("a photo of a chair", "의자");
                put("a photo of a bench", "의자");
                put("a photo of an armchair", "의자");
                put("a photo of a clothes rack", "행거·옷장");
                put("a photo of a wardrobe", "행거·옷장");
                put("a photo of a vanity", "화장대·콘솔");
                put("a photo of a dressing table", "화장대·콘솔");
                put("a photo of a console table", "화장대·콘솔");
            }
        };

        Map<String, List<List<Double>>> categoryEmbeddings = new HashMap<>();
        for (String prompt : categories.keySet()) {
            String category = categories.get(prompt);
            List<Double> embedding = visionServiceClient.extractEmbeddingFromText(prompt);
            if (embedding == null || embedding.isEmpty()) {
                log.warn("임베딩이 비어 있습니다. 카테고리: {}", category);
                throw new IllegalStateException("임베딩이 비어 있습니다. 카테고리: " + category);
            }
            if (categoryEmbeddings.containsKey(category)) {
                categoryEmbeddings.get(category).add(embedding);
            }
            else {
                categoryEmbeddings.put(category, new ArrayList<List<Double>>() {{
                    add(embedding);
                }});
            }
        }
        for(Category category : categoryRepository.findAll()) {
            if(categoryEmbeddings.containsKey(category.getCategoryName())) {
                List<List<Double>> embeddings = categoryEmbeddings.get(category.getCategoryName());
                // 평균 임베딩 계산
                List<Double> averageEmbedding = new ArrayList<>();
                for (int i = 0; i < embeddings.get(0).size(); i++) {
                    double sum = 0;
                    for (List<Double> emb : embeddings) {
                        sum += emb.get(i);
                    }
                    averageEmbedding.add(sum / embeddings.size());
                }
                normalize(averageEmbedding);
                category.setEmbedding(averageEmbedding.toString());
                categoryRepository.save(category);
            }
        }
        log.info("카테고리 임베딩 초기화 완료");
        return "Category embeddings initialized successfully.";
    }

    public static void normalize(List<Double> vector) {
        double norm = 0.0;
        for (Double v : vector) {
            norm += v * v;
        }
        norm = Math.sqrt(norm);
        if (norm > 0) {
            for (int i = 0; i < vector.size(); i++) {
                vector.set(i, vector.get(i) / norm);
            }
        }
    }

}