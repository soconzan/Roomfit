package org.example.roomfit.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class R2Service {

    private final S3Client s3Client;

    @Value("${cloudflare.r2.bucket-name}")
    private String bucketName;

    @Value("${cloudflare.r2.public-url-prefix:}")
    private String publicUrlPrefix; // R2 커스텀 도메인이 설정된 경우 파일 URL 생성을 위해 사용

    // 파일 업로드 메서드: MultipartFile과 byte[] 두 가지 형태로 지원
    public String uploadFile(MultipartFile file, String dirName) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        try {
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : "";
            String fileName = dirName + "/" + UUID.randomUUID() + extension;

            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .contentType(file.getContentType())
                    .build();

            s3Client.putObject(putObjectRequest, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

            log.info("Cloudflare R2에 파일 업로드 완료: {}", fileName);

            // 커스텀 도메인(Public URL)이 있으면 해당 주소로, 없으면 버킷 기준 주소(Private/예시)로 반환
            if (!publicUrlPrefix.isEmpty()) {
                return publicUrlPrefix + "/" + fileName;
            }
            return fileName; // 임시 반환
        } catch (IOException e) {
            log.error("파일 업로드 중 에러 발생", e);
            throw new RuntimeException("R2 업로드 실패", e);
        }
    }

    // byte[] 데이터를 직접 업로드하는 메서드: 파일이 MultipartFile이 아닌 경우에도 지원
    public String uploadFile(byte[] data, String dirName, String extension, String contentType) {
        if (data == null || data.length == 0) {
            return null;
        }
        try {
            String fileName = dirName + "/" + UUID.randomUUID() + extension;
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .contentType(contentType)
                    .build();

            s3Client.putObject(putObjectRequest, RequestBody.fromBytes(data));

            log.info("Cloudflare R2에 파일 업로드 완료: {}", fileName);
            if (publicUrlPrefix != null && !publicUrlPrefix.isEmpty()) {
                return publicUrlPrefix + "/" + fileName;
            }
            return fileName;
        } catch (Exception e) {
            log.error("파일 업로드 중 에러 발생", e);
            throw new RuntimeException("R2 업로드 실패", e);
        }
    }

    public void deleteFile(String fileUrl) {
        String key = extractObjectKey(fileUrl);
        if (key == null || key.isBlank()) {
            log.warn("R2 삭제 대상 key를 찾을 수 없습니다: {}", fileUrl);
            return;
        }

        DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .build();

        s3Client.deleteObject(deleteObjectRequest);
        log.info("Cloudflare R2 파일 삭제 완료: {}", key);
    }

    /**
     * R2에서 파일을 다운로드하는 메서드
     * 비동기 재처리 시 사용
     */
    public byte[] downloadFile(String fileUrl) {
        try {
            String key = extractObjectKey(fileUrl);
            if (key == null || key.isBlank()) {
                log.warn("R2 다운로드 대상 key를 찾을 수 없습니다: {}", fileUrl);
                return null;
            }

            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            byte[] data = s3Client.getObject(getObjectRequest).readAllBytes();
            log.info("Cloudflare R2 파일 다운로드 완료: {}, size={}", key, data.length);
            return data;

        } catch (IOException e) {
            log.error("R2 파일 다운로드 중 에러 발생: {}, error={}", fileUrl, e.getMessage(), e);
            return null;
        } catch (Exception e) {
            log.error("R2 파일 다운로드 중 예상치 못한 에러 발생: {}, error={}", fileUrl, e.getMessage(), e);
            return null;
        }
    }

    private String extractObjectKey(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank()) {
            return null;
        }

        if (publicUrlPrefix != null && !publicUrlPrefix.isBlank()
                && fileUrl.startsWith(publicUrlPrefix + "/")) {
            return fileUrl.substring(publicUrlPrefix.length() + 1);
        }

        return fileUrl;
    }
}
