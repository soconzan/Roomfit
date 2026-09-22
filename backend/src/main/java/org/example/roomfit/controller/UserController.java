package org.example.roomfit.controller;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.dto.UserResponseDTO;
import org.example.roomfit.jwt.JwtTokenProvider;
import org.example.roomfit.response.ApiResponse;
import org.example.roomfit.service.AuthService;
import org.example.roomfit.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@RequestMapping("/api/users")
@Controller
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponseDTO>> getMyInfo(HttpServletRequest request)
    {
        log.info("Get user info request received");
        String token = jwtTokenProvider.resolveToken(request);
        return ResponseEntity.ok(new ApiResponse<>(true, null, userService.getUserInfo(token)));
    }
}
