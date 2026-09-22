package org.example.roomfit.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserRegisterRequestDTO {
    private String nickname;    // 닉네임
    private String username;    // id
    private String password;
    private String imageUrl;
}
