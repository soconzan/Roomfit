package org.example.roomfit.service;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;

import org.example.roomfit.util.RecommendCategory;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import lombok.RequiredArgsConstructor;

/**
 * Grounded-SAM API Client Service
 * Integrates with Python FastAPI server for image segmentation
 */
@Service
@RequiredArgsConstructor
public class GroundedSAMClient {

    @Value("${grounded-sam.api.url:http://localhost:8002}")
    private String apiUrl;

    // Instantiate RestTemplate locally to avoid requiring a RestTemplate bean in the context
    private final RestTemplate restTemplate = new RestTemplate();

    // private final String prompt = "chair . table . sofa . bed . lamp . bookshelf . cabinet . rug . curtain . furniture . wall . floor";

    /**
     * Segment image based on text prompt
     *
     * @param imageFile: Uploaded image file
     * @return Map containing segmented objects with base64 images
     * @throws IOException if reading the uploaded file bytes fails
     */
    public Map<String, Object> segmentImage(MultipartFile imageFile) throws IOException {
        return segmentImage(imageFile.getBytes(), imageFile.getOriginalFilename(), null);
    }

    public Map<String, Object> segmentImage(byte[] imageBytes, String filename, String textPrompt) {
        // Prepare multipart request
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", new FileInputStreamResource(imageBytes, filename));
        body.add("text_prompt", textPrompt != null ? textPrompt : RecommendCategory.getDetectCategory());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        HttpEntity<MultiValueMap<String, Object>> requestEntity =
                new HttpEntity<>(body, headers);

        // Call API
        try {
            ResponseEntity<String> response = restTemplate.postForEntity(
                    apiUrl + "/segment",
                    requestEntity,
                    String.class
            );

            return parseResponse(response.getBody());
        } catch (RestClientException e) {
            throw new RuntimeException("Failed to segment image: " + e.getMessage(), e);
        }
    }

    /**
     * Health check - verify API server is running
     */
    public boolean isHealthy() {
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(
                    apiUrl + "/health",
                    String.class
            );
            return response.getStatusCode().value() == 200;
        } catch (RestClientException e) {
            System.err.println("Health check failed: " + e.getMessage());
            return false;
        }
    }

    /**
     * Parse API response JSON
     */
    private Map<String, Object> parseResponse(String jsonResponse) {
        try {
            Map<String, Object> result = new HashMap<>();
            JSONObject json = new JSONObject(jsonResponse);

            result.put("status", json.getString("status"));
            result.put("processingTime", json.getDouble("processing_time"));
            result.put("totalObjects", json.getInt("total_objects"));

            // Parse objects
            List<Map<String, Object>> objects = new ArrayList<>();
            JSONArray objectsArray = json.getJSONArray("objects");

            for (int i = 0; i < objectsArray.length(); i++) {
                JSONObject obj = objectsArray.getJSONObject(i);
                Map<String, Object> objectMap = new HashMap<>();
                objectMap.put("tag", obj.getString("tag"));
                objectMap.put("index", obj.getInt("index"));
                objectMap.put("image", rotateBase64Image90(obj.getString("image"))); // base64
                objects.add(objectMap);
            }

            result.put("objects", objects);
            return result;
        } catch (JSONException e) {
            throw new RuntimeException("Invalid JSON response from Grounded-SAM API", e);
        }
    }

    private String rotateBase64Image90(String base64Image) {
    try {
        byte[] imageBytes = Base64.getDecoder().decode(base64Image);

        BufferedImage original =
                ImageIO.read(new ByteArrayInputStream(imageBytes));

        int width = original.getWidth();
        int height = original.getHeight();

        BufferedImage rotated =
                new BufferedImage(height, width, original.getType());

        Graphics2D g2d = rotated.createGraphics();

        // 시계 방향 90도 회전
        g2d.translate(height, 0);
        g2d.rotate(Math.toRadians(90));

        g2d.drawImage(original, 0, 0, null);
        g2d.dispose();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(rotated, "png", baos);

        return Base64.getEncoder().encodeToString(baos.toByteArray());

    } catch (Exception e) {
        throw new RuntimeException("Failed to rotate image", e);
    }
}

    public byte[] segmentCenterCrop(byte[] imageBytes) {
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", new FileInputStreamResource(imageBytes, "center-crop.png"));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        HttpEntity<MultiValueMap<String, Object>> requestEntity =
                new HttpEntity<>(body, headers);

        ResponseEntity<String> response = restTemplate.postForEntity(
                apiUrl + "/segment_center",
                requestEntity,
                String.class
        );

        JSONObject json = new JSONObject(response.getBody());
        JSONArray objectsArray = json.optJSONArray("objects");

        if (objectsArray == null || objectsArray.isEmpty()) {
            throw new RuntimeException("No objects returned from Grounded-SAM center segmentation");
        }

        JSONObject object = objectsArray.getJSONObject(0);
        return decodeBase64Image(object.getString("image"));
    }

    /**
     * Decode base64 image and save to file
     */
    public byte[] decodeBase64Image(String base64Image) {
        return Base64.getDecoder().decode(base64Image);
    }

    /**
     * Helper class for MultipartFile input
     */
    public static class FileInputStreamResource extends ByteArrayResource {

        private final String filename;

        public FileInputStreamResource(byte[] bytes, String filename) {
            super(bytes);
            this.filename = filename;
        }

        public FileInputStreamResource(MultipartFile file) throws IOException {
            this(file.getBytes(), file.getOriginalFilename());
        }

        @Override
        public String getFilename() {
            return filename;
        }
    }
}
