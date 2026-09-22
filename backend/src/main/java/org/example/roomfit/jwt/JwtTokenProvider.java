package org.example.roomfit.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.example.roomfit.service.UserDetailService;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.crypto.SecretKey;
import java.security.Key;
import java.util.Base64;
import java.util.Date;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Component
public class JwtTokenProvider {

    private String AUTHORITIES_KEY = "roomfit-jwt-secret-key-2024-abcdefghijklmn";

    private long tokenValidtime = 300 * 60 * 1000L; // 30분

    private final long refreshTokenValidTime = 30 * 24 * 60 * 60 * 1000L; // 30일

    private Key key;

    private final UserDetailService userDetailService;

    @PostConstruct
    protected void init()
    {
        byte[] keyBytes = Base64.getDecoder().decode(
                Base64.getEncoder().encodeToString(AUTHORITIES_KEY.getBytes())
        );
        // SecretKey 객체 생성 (verifyWith()에서 SecretKey 타입 요구)
        this.key = Keys.hmacShaKeyFor(keyBytes);
    }

    // 사용자 권한 정보 추출
    public String createToken(Authentication authentication)
    {
        // 현재 시간과 유효 기간 설정
        long now = (new Date()).getTime();
        Date validity = new Date(now + tokenValidtime);

        // JWT Token 생성
        return Jwts.builder()
                .subject(authentication.getName())
                .expiration(validity)
                .signWith(key)
                .compact();
    }

    // refresh token 발급
    public String createRefreshToken(Authentication authentication)
    {
        long now = new Date().getTime();
        Date validity = new Date(now + refreshTokenValidTime);
        return Jwts.builder()
                .subject(authentication.getName())
                .expiration(validity)
                .signWith(key)
                .compact();
    }

    // Request Header에서 token 값 가져오기
    public String resolveToken(HttpServletRequest request)
    {
        String bearerToken = request.getHeader("Authorization");
        if(StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")){
            return bearerToken.substring(7);    // Bearer 잘라내기
        }
        return null;
    }

    // JWT 토큰에서 인증 정보 조회
    public Authentication getAuthentication(String token)
    {
        UserDetails userDetails = userDetailService.loadUserByUsername(this.getUserPk(token));
        System.out.println("token: " + userDetails);
        return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
    }

    // token 서명 검증
    public String getUserPk(String token)
    {
        return Jwts.parser().verifyWith((SecretKey) key).build().parseSignedClaims(token).getPayload().getSubject();
    }

    // 토큰 유효성 + 만료일자 확인
    public boolean validateToken(String jwtToken)
    {
        try{
            Jws<Claims> claims = Jwts.parser().verifyWith((SecretKey) key)
                    .build().parseSignedClaims(jwtToken);
            return !claims.getPayload().getExpiration().before(new Date());
        }catch (Exception e)
        {
            return false;
        }
    }
}
