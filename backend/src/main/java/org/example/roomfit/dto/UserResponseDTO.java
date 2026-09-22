package org.example.roomfit.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class UserResponseDTO {
    private String username;
    private String nickname;
    private String imageUrl;
}
