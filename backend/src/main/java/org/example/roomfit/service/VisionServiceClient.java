package org.example.roomfit.service;

import java.util.List;
import java.util.Map;

import org.example.roomfit.util.CustomMultipartFile;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class VisionServiceClient {

    private RestClient restClient;

    @Value("${fastapi.server.url}")
    private String fastApiServerUrl;

    @PostConstruct
    public void init() {
        // RestClient를 생성자 대신 @PostConstruct에서 초기화
        this.restClient = RestClient.builder()
                .baseUrl(fastApiServerUrl)
                .build();
        log.info("VisionServiceClient 초기화 완료: FastAPI URL = {}", fastApiServerUrl);
    }

    public List<Float> getEmbeddingFromFastApi(MultipartFile file) {
        return getEmbeddingFromFastApi(file.getResource());
    }

    public List<Float> getEmbeddingFromFastApi(byte[] imageBytes, String filename) {
        // 파일 형식 검증
        if (!isValidImageFormat(filename)) {
            throw new IllegalArgumentException("지원하지 않는 이미지 형식입니다: " + filename);
        }

        org.springframework.core.io.ByteArrayResource resource = new org.springframework.core.io.ByteArrayResource(imageBytes) {
            @Override
            public String getFilename() {
                return filename; // FastAPI에서 파일로 인식하기 위해 파일명 필수
            }
        };
        return getEmbeddingFromFastApi(resource);
    }

    private boolean isValidImageFormat(String filename) {
        return filename.matches("(?i).*\\.(jpg|jpeg|png|gif|webp|bmp)$");
    }

    public List<Float> getEmbeddingFromFastApi(Resource resource) {
        // Multipart 요청을 위한 바디 생성
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", resource); // Resource를 직접 추가

        // FastAPI 호출
        Map<String, Object> response = restClient.post()
                .uri("/extract-features")
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .body(body)
                .retrieve()
                .body(Map.class);

        // 결과 파싱 (FastAPI가 {"embedding": [...]} 형태로 반환한다고 가정)
        List<Double> embeddingList = (List<Double>) response.get("embedding");

        // List<Double>을 List<Float>로 변환
        return embeddingList.stream()
                .map(Double::floatValue)
                .toList();
    }

    // 배경 제거 요청을 위한 메서드
    public byte[] removeBackgroundFromFastApi(MultipartFile file) {
        // Multipart 요청을 위한 바디 생성
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", file.getResource()); // MultipartFile을 Resource로 변환하여 추가

        // FastAPI 호출
        return restClient.post()
                .uri("/remove-background")
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .accept(MediaType.IMAGE_PNG)
                .body(body)
                .retrieve()
                .body(byte[].class); // 배경 제거된 이미지를 메모리 상의 byte 배열로 반환
    }

    // 배경 제거 요청 - byte[] 버전 (비동기 처리용)
    public byte[] removeBackgroundFromFastApi(Resource resource) {
        // Multipart 요청을 위한 바디 생성
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", resource);

        // FastAPI 호출
        return restClient.post()
                .uri("/remove-background")
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .accept(MediaType.IMAGE_PNG)
                .body(body)
                .retrieve()
                .body(byte[].class);
    }

    public List<MultipartFile> removeImagesBackgroundFromFastApi(List<MultipartFile> files) {
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        for (MultipartFile file : files) {
            body.add("files", file.getResource());
        }

        byte[] responseBytes = restClient.post()
                .uri("/remove-background-batch")
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .accept(MediaType.parseMediaType("multipart/mixed"))
                .body(body)
                .retrieve()
                .body(byte[].class); // multipart/mixed 전체 응답을 byte 배열로 가져옴

        List<byte[]> extractedBytes = extractImagesFromMultipart(responseBytes, "batch_images_boundary");

        List<MultipartFile> resultFiles = new java.util.ArrayList<>();
        for (int i = 0; i < extractedBytes.size(); i++) {
            MultipartFile originalFile = i < files.size() ? files.get(i) : null;
            String name = originalFile != null ? originalFile.getName() : "files";
            String origName = originalFile != null ? "no_bg_" + originalFile.getOriginalFilename() : "no_bg_image.png";

            resultFiles.add(new CustomMultipartFile(extractedBytes.get(i), name, origName, "image/png"));
        }

        return resultFiles;
    }


    private List<byte[]> extractImagesFromMultipart(byte[] data, String boundary) {
        List<byte[]> result = new java.util.ArrayList<>();
        if (data == null) return result;

        byte[] separator = ("--" + boundary).getBytes(java.nio.charset.StandardCharsets.UTF_8);
        byte[] headerEnd = "\r\n\r\n".getBytes(java.nio.charset.StandardCharsets.UTF_8);

        int i = 0;
        while (i < data.length) {
            int matchPart = indexOf(data, separator, i);
            if (matchPart == -1) break;

            int headerEndIdx = indexOf(data, headerEnd, matchPart);
            if (headerEndIdx == -1) break;

            int contentStart = headerEndIdx + headerEnd.length;
            int nextBoundaryIdx = indexOf(data, separator, contentStart);
            if (nextBoundaryIdx == -1) break;

            // 다음 boundary 앞의 \r\n 제거
            int contentEnd = nextBoundaryIdx - 2;
            if (contentEnd > contentStart) {
                byte[] imageBytes = new byte[contentEnd - contentStart];
                System.arraycopy(data, contentStart, imageBytes, 0, imageBytes.length);
                result.add(imageBytes);
            }

            i = nextBoundaryIdx;
        }
        return result;
    }

    private int indexOf(byte[] data, byte[] pattern, int start) {
        for (int i = start; i <= data.length - pattern.length; i++) {
            boolean found = true;
            for (int j = 0; j < pattern.length; j++) {
                if (data[i + j] != pattern[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return i;
        }
        return -1;
    }

    // 지배색 추출 요청 (MultipartFile)
    public List<List<Float>> extractDominantColors(MultipartFile file) {
        return extractDominantColors(file.getResource());
    }

    // 지배색 추출 요청 (byte[])
    public List<List<Float>> extractDominantColors(byte[] imageBytes, String filename) {
        org.springframework.core.io.ByteArrayResource resource = new org.springframework.core.io.ByteArrayResource(imageBytes) {
            @Override
            public String getFilename() {
                return filename;
            }
        };
        return extractDominantColors(resource);
    }

    // 지배색 추출 요청 (Resource)
    public List<List<Float>> extractDominantColors(Resource resource) {
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", resource);
        try{
            log.info("지배색 추출 요청: filename={}, size={}", resource.getFilename(), resource.contentLength());
        } catch (Exception e) {
            log.error("파일 정보 조회 중 에러 발생", e);
        }

        String responseRaw = restClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path("/extract-dominant-colors")
                        .queryParam("n_segments", 20)
                        .queryParam("compactness", 10)
                        .queryParam("sigma", 1)
                        .queryParam("top_k", 5)
                        .queryParam("resize_max_side", 512)
                        .build())
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .accept(MediaType.APPLICATION_JSON)
                .body(body)
                .retrieve()
                .body(String.class);

        log.info("FastAPI 지배색 추출 응답 원본: {}", responseRaw);

        if (responseRaw == null || responseRaw.isEmpty()) {
            return List.of();
        }

        try {
            org.springframework.boot.json.JsonParser jsonParser = org.springframework.boot.json.JsonParserFactory.getJsonParser();
            List<Object> parsedList;

            try {
                parsedList = jsonParser.parseList(responseRaw);
            } catch (Exception ex) {
                log.warn("JSON 리스트 파싱 실패, 객체 형태로 파싱을 시도합니다. 원본: {}", responseRaw);
                Map<String, Object> parsedMap = jsonParser.parseMap(responseRaw);

                // Map 안에서 List 형태의 데이터(예: "colors": [...])를 찾아서 사용
                Object possibleList = parsedMap.values().stream()
                        .filter(v -> v instanceof List)
                        .findFirst()
                        .orElseThrow(() -> new RuntimeException("응답에서 리스트 데이터를 찾을 수 없습니다."));

                parsedList = (List<Object>) possibleList;
            }

            return parsedList.stream()
                    .map(obj -> {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> map = (Map<String, Object>) obj;
                        return map;
                    })
                    .map(colorMap -> {
                        @SuppressWarnings("unchecked")
                        List<Number> colorVector = (List<Number>) colorMap.get("color_vector");
                        if (colorVector == null) {
                            @SuppressWarnings("unchecked")
                            List<Number> rgb = (List<Number>) colorMap.get("rgb");
                            colorVector = rgb;
                        }

                        if (colorVector == null) {
                            return List.of(0f, 0f, 0f); // Fallback
                        }

                        return colorVector.stream().map(Number::floatValue).toList();
                    })
                    .toList();
        } catch (Exception e) {
            log.error("응답 파싱 중 에러 발생", e);
            throw new RuntimeException("지배색 추출 응답 파싱 실패", e);
        }
    }

    public List<Double> extractEmbeddingFromText(String text) {
        try {

            MultiValueMap<String, String> formData =
                    new LinkedMultiValueMap<>();

            formData.add("text", text);

            Map<String, Object> response =
                    restClient.post()
                            .uri("/extract-feature-text")
                            .contentType(
                                    MediaType.APPLICATION_FORM_URLENCODED
                            )
                            .body(formData)
                            .retrieve()
                            .body(Map.class);

            if (response == null ||
                    !response.containsKey("embedding")) {
                throw new RuntimeException(
                        "embedding 필드가 응답에 없습니다."
                );
            }

            List<?> rawEmbedding =
                    (List<?>) response.get("embedding");

            List<Double> embedding =
                    rawEmbedding.stream()
                            .map(value -> ((Number) value).doubleValue())
                            .toList();

            return embedding;

        } catch (Exception e) {
            log.error(
                    "텍스트 임베딩 추출 중 에러 발생",
                    e
            );

            throw new RuntimeException(
                    "텍스트 임베딩 추출 실패",
                    e
            );
        }
    }

}