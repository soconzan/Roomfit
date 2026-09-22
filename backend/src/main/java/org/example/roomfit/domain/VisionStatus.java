package org.example.roomfit.domain;

import lombok.Getter;

/**
 * 상품 이미지 비전 처리 상태
 *
 * PENDING: 처리 대기 중
 * PROCESSING: 비동기 작업 진행 중
 * DONE: 임베딩/색상 추출 완료
 * FAILED: 처리 실패
 */
@Getter
public enum VisionStatus {
    PENDING("PENDING"),
    PROCESSING("PROCESSING"),
    DONE("DONE"),
    FAILED("FAILED");

    private final String value;

    VisionStatus(String value) {
        this.value = value;
    }
}
