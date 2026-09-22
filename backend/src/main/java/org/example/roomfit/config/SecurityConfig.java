package org.example.roomfit.config;

import lombok.RequiredArgsConstructor;
import org.example.roomfit.jwt.JwtAuthenticationFilter;
import org.example.roomfit.jwt.JwtTokenProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;

    // 패스워드 인코더 빈
    @Bean
    public PasswordEncoder passwordEncoder()
    {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, CorsConfigurationSource corsConfigurationSource) throws  Exception {
        http
                .csrf(csrf -> csrf.disable())   //csrf 비활성화
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))   // 세션 비활성화
                .formLogin(form -> form.disable())
                .httpBasic(AbstractHttpConfigurer::disable) //JWT 기반 인증 사용 예정
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider),
                        UsernamePasswordAuthenticationFilter.class) // jwt 토큰 추가
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(   // 인증 없이 허용(추후 추가 예정) -> 테스트할거라 일단 다 넣어놓음
//                                "/api/auth/register",
//                                "/api/auth/login",
//                                "/api/users/**",
//                                "/api/auth/**",
//                                "/api/categories",
//                                "/api/products/**",
//                                "/api/recommend/",
                                "/api/**",
                                "/*.html",
                                "/image/**",
                                "/test"
                        ).permitAll()
                        .requestMatchers(   // 인증 필요
                                "/api/users/logout"
                        ).authenticated()
                        .anyRequest().authenticated());   // 그 외 요청은 모두 인증 필요

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource()
    {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("*"));  //플러터 서버(추후 수정) http://localhost:3000
        configuration.setAllowedMethods(List.of("GET", "POST", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration); // 모든 경로에 대해 CORS 설정을 사용
        return source;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception{
        return authenticationConfiguration.getAuthenticationManager();
    }
}
