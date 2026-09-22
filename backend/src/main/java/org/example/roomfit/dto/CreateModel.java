package org.example.roomfit.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateModel {
    private Long productId;
    private byte[] imageFront;
    private byte[] imageLeft;
    private byte[] imageRight;
    private byte[] imageBack;
}
