package org.example.roomfit.service;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import org.example.roomfit.dto.CreateModel;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class FastApiService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String FASTAPI_URL = "http://localhost:8001/generate"; // FastAPI 주소로 변경하세요
    private final R2Service r2Service; // R2 파일 업로드 서비스를 주입받습니다

    // 블로킹 I/O 작업(HTTP 통신)을 위해 가상 스레드 또는 별도 풀을 사용합니다. 공용 ForkJoinPool 고갈을 방지합니다.
    private final Executor executor = Executors.newVirtualThreadPerTaskExecutor();

    public CompletableFuture<String> request3DModelGeneration(CreateModel createModel) {
        // 최소 하나의 이미지가 업로드 되었는지 검증합니다.
        if (!hasAtLeastOneImage(createModel)) {
            CompletableFuture<String> future = new CompletableFuture<>();
            future.completeExceptionally(new IllegalArgumentException("최소 한 장 이상의 이미지를 업로드해야 합니다."));
            return future;
        }
        // 비동기적으로 3D 모델 생성 요청을 처리합니다. CompletableFuture를 반환하여 호출자가 결과를 기다릴 수 있도록 합니다.
        return CompletableFuture.supplyAsync(() -> {
            try {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);

                Map<String, Object> requestBody = new HashMap<>();
                Map<String, String> imageMap = new HashMap<>();

                addBase64Image(imageMap, "front", createModel.getImageFront());
                addBase64Image(imageMap, "left", createModel.getImageLeft());
                addBase64Image(imageMap, "right", createModel.getImageRight());
                addBase64Image(imageMap, "back", createModel.getImageBack());

                // 단일 이미지(front)만 있는 경우 image를 단일 String으로 전송,
                // 여러 장의 이미지가 있는 경우 multi-view dict 형식으로 전송
                log.info("업로드된 이미지 수: " + imageMap.size());
                if (imageMap.size() > 0) {
                    requestBody.put("images", imageMap);
                } else {
                    throw new IllegalArgumentException("업로드된 이미지가 없습니다.");
                }

                requestBody.put("texture", true);
                requestBody.put("productId", createModel.getProductId()); // 기존 로직 유지를 위해 product ID 추가

                HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);

                // FastAPI 서버가 .glb 바이너리 파일을 반환하므로 String.class 대신 byte[].class로 응답을 수신합니다.
                ResponseEntity<byte[]> response = restTemplate.postForEntity(FASTAPI_URL, requestEntity, byte[].class);
                byte[] glbData = response.getBody();

                if (glbData != null && glbData.length > 0) {
                    // 수신받은 모델 바이너리 파일을 Cloudflare R2에 업로드
                    String modelUrl = r2Service.uploadFile(glbData, "models", ".glb", "model/gltf-binary");
                    log.info("3D 모델 생성 및 R2 업로드 완료! 모델 URL: {}", modelUrl);
                    return modelUrl;
                } else {
                    throw new RuntimeException("응답된 바이너리 파일이 비어 있습니다.");
                }
            } catch (Exception e) {
                log.error("3D 모델 생성 중 오류 발생: {}", e.getMessage(), e);
                throw new RuntimeException(e);
            }
        }, executor); // 생성한 스레드 풀(executor)을 인자로 전달
    }

    private void addBase64Image(Map<String, String> imageMap, String key, MultipartFile file) {
        if (file != null && !file.isEmpty()) {
            try {
                String base64 = Base64.getEncoder().encodeToString(file.getBytes());
                imageMap.put(key, base64);
            } catch (IOException e) {
                log.error("{} 이미지 인코딩 중 오류 발생: {}", key, e.getMessage());
            }
        }
    }

    private void addBase64Image(Map<String, String> imageMap, String key, byte[] bytes) {
        if (bytes != null && bytes.length > 0) {
            String base64 = Base64.getEncoder().encodeToString(bytes);
            imageMap.put(key, base64);
        }
    }

    private boolean hasAtLeastOneImage(CreateModel model) {
        return (model.getImageFront() != null) ||
               (model.getImageLeft() != null) ||
               (model.getImageRight() != null) ||
               (model.getImageBack() != null);
    }
}
