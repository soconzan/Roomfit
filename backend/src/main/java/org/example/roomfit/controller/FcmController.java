package org.example.roomfit.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.dto.FcmTokenRequestDTO;
import org.example.roomfit.response.ApiResponse;
import org.example.roomfit.service.FcmService;
import org.example.roomfit.service.UserDetailService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.userdetails.User;

@RestController
@RequestMapping("/api/fcm")
@RequiredArgsConstructor
@Slf4j
public class FcmController {

    private final FcmService fcmService;
    // FCM 토큰 저장 API
    @PostMapping("/token")
    public ResponseEntity<ApiResponse> saveFcmToken(@RequestBody FcmTokenRequestDTO request, @AuthenticationPrincipal User userDetails) { //우리가 만든 User 클래스 아님.
        // userDetails.getUsername()로 사용자 정보 가져오기
        log.info("saveFcmToken called");
        try{
            log.info("FCM 토큰 저장 요청: username={}, fcmToken={}", userDetails.getUsername(), request.getFcmToken());
            fcmService.saveFcmToken(userDetails.getUsername(), request.getFcmToken());
            return ResponseEntity.ok(new ApiResponse(true, "FCM 토큰 저장 성공", null));
        } catch (Exception e) {
            log.error("FCM 토큰 저장 실패: {}", e.getMessage());
            return ResponseEntity.status(500).body(new ApiResponse(false, "FCM 토큰 저장 실패: " + e.getMessage(), null));
        }
    }

    @DeleteMapping("/token")
    public ResponseEntity<ApiResponse> deleteFcmToken(@AuthenticationPrincipal User userDetails) {
        log.info("deleteFcmToken called");
        try {
            fcmService.deleteFcmToken(userDetails.getUsername());
            return ResponseEntity.ok(new ApiResponse(true, "FCM 토큰 삭제 성공", null));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(new ApiResponse(false, "FCM 토큰 삭제 실패: " + e.getMessage(), null));
        }
    }

}
