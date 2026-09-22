package org.example.roomfit.service;

import io.jsonwebtoken.ExpiredJwtException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.example.roomfit.domain.User;
import org.example.roomfit.dto.UserRegisterRequestDTO;
import org.example.roomfit.jwt.JwtTokenProvider;
import org.example.roomfit.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.UUID;

@Component
@RequiredArgsConstructor
// 회원가입, 중복검사, 로그인, 토큰 발급, 재발급
public class AuthService {
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;
//    private final UserDetailService userDetailService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public Map<String, String> authenticate(String username, String password) throws BadCredentialsException
    {
        // 아이디 혹은 비번 불일치
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BadCredentialsException("INVALID_CREDENTIALS"));

        if(!passwordEncoder.matches(password, user.getPassword())){
            throw new BadCredentialsException("INVALID_CREDENTIALS");
        }

        // username, password로 인증 객체 생성
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(username, password);

        // DB에서 유저를 찾고 비밀번호 검증
        Authentication authentication = authenticationManager.authenticate(authenticationToken);

        // 인증 성공 시 토큰 발행
        String accessToken = jwtTokenProvider.createToken(authentication);
        String refreshToken = jwtTokenProvider.createRefreshToken(authentication);
        // (임시) create product 용 userId 반환
        String userId = String.valueOf(user.getUserId());

        return Map.of("accessToken", accessToken, "refreshToken", refreshToken, "userId", userId);  // (임시) userId 추후 정리
    }

    public Map<String, String> reissue(String refreshToken)
    {
        // token 검증
        if(!jwtTokenProvider.validateToken(refreshToken))
        {
            throw new ExpiredJwtException(null, null, "EXPIRED_REFRESH_TOKEN");
        }

        // Refresh Token에서 Authentication 추출
        Authentication authentication = jwtTokenProvider.getAuthentication(refreshToken);

        // new Token 발급
        String newAccessToken = jwtTokenProvider.createToken(authentication);
        String newRefreshToken = jwtTokenProvider.createRefreshToken(authentication);

        return Map.of("newAccessToken", newAccessToken, "newRefreshToken", newRefreshToken);
    }

    // 회원가입
    @Transactional
    public void save(UserRegisterRequestDTO dto)
    {
        User user = User.builder()
                .userId(UUID.randomUUID())
                .nickname(dto.getNickname())
                .username(dto.getUsername())
                .password(passwordEncoder.encode(dto.getPassword()))
                .build();
        userRepository.save(user);
    }

    // id 중복 검사
    public void checkDuplicateUsername(String username)
    {
        System.out.println("idDuplicate" + userRepository.existsByUsername(username));
        if(userRepository.existsByUsername(username))
        {
            throw new RuntimeException("이미 존재하는 아이디입니다.");
        }
    }

    // 닉네임 중복 검사
    public void checkDuplicateName(String nickname)
    {
        if(userRepository.existsByNickname(nickname))
        {
            throw new RuntimeException("이미 존재하는 닉네임입니다.");
        }
    }

}
