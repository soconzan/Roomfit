package org.example.roomfit.service;

import lombok.RequiredArgsConstructor;
import org.example.roomfit.domain.User;
import org.example.roomfit.dto.UserResponseDTO;
import org.example.roomfit.jwt.JwtTokenProvider;
import org.example.roomfit.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
// 개인정보 조회
public class UserService {
    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;

    public UserResponseDTO getUserInfo(String token)
    {
        String username = jwtTokenProvider.getUserPk(token);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("USER_NOT_FOUND"));

        return new UserResponseDTO(user.getUsername(), user.getNickname(), user.getImageUrl());
    }
}
