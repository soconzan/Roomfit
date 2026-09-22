package org.example.roomfit.repository;

import org.example.roomfit.domain.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface FcmRepository extends JpaRepository<FcmToken, Long> {
    // FCM 토큰 저장, 조회, 삭제 등의 메서드 정의
    @Query("SELECT f FROM FcmToken f WHERE f.userId.userId = :userId")
    FcmToken findByUserId(@Param("userId") UUID userId);
}
