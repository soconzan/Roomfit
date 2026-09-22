package org.example.roomfit.controller;

import io.jsonwebtoken.ExpiredJwtException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.dto.UserRegisterRequestDTO;
import org.example.roomfit.response.ApiResponse;
import org.example.roomfit.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RequestMapping("/api/auth")
@RestController
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Void>> register(@RequestBody UserRegisterRequestDTO request)
    {
        log.info("Register request called");
        try{
            log.info("Register request received for username: {}", request.getUsername());
            authService.save(request);
            return ResponseEntity.ok(new ApiResponse<>(true, "회원가입이 완료되었습니다.", null));
        } catch (RuntimeException e) {
            return ResponseEntity.ok(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Map<String, String>>> login(@RequestBody Map<String, String> user)
    {
        log.info("Login request called");
        try {
            log.info("Login request received for username: {}", user.get("username"));
            Map<String, String> tokens = authService.authenticate(user.get("username"), user.get("password"));
            return ResponseEntity.ok(new ApiResponse<>(true, null, tokens));
        }catch (BadCredentialsException e)
        {
            return ResponseEntity.ok(new ApiResponse<>(false, "INVALID_CREDENTIALS", null));
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<Map<String, String>>> refresh(@RequestBody Map<String, String> request)
    {
        log.info("Token refresh request called");
        try{
            log.info("Token refresh request received with refreshToken: {}", request.get("refreshToken"));
            String refreshToken = request.get("refreshToken");
            // refresh Token으로 재생성
            Map<String, String> tokens = authService.reissue(refreshToken);
            return ResponseEntity.ok(new ApiResponse<>(true, null, tokens));
        }catch (ExpiredJwtException e)
        {
            // 토큰 만료
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "EXPIRED_REFRESH_TOKEN", null));
        }
    }

    // 아이디 중복 검사
    @GetMapping("/check-id")
    public ResponseEntity<ApiResponse<Void>> checkId(@RequestParam String username)
    {
        log.info("Check username request called");
        try{
            log.info("Check username request received for username: {}", username);
            authService.checkDuplicateUsername(username);
            return ResponseEntity.ok(new ApiResponse<>(true, "사용 가능한 아이디입니다.", null));
        }catch (RuntimeException e)
        {
            return ResponseEntity.ok(new ApiResponse<>(false, "이미 존재하는 이이디입니다.", null));
        }
    }

    // 닉네임 중복 검사
    @GetMapping("/check-name")
    public ResponseEntity<ApiResponse<Void>> checkName(@RequestParam String name)
    {
        log.info("Check nickname request called");
        try{
            log.info("Check nickname request received for name: {}", name);
            authService.checkDuplicateName(name);
            return ResponseEntity.ok(new ApiResponse<>(true, "사용 가능한 닉네임입니다.", null));
        }catch (RuntimeException e)
        {
            return ResponseEntity.ok(new ApiResponse<>(false, "이미 존재하는 닉네임입니다.", null));
        }
    }
}
