package org.example.roomfit.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "imagefiles")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class ImageFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "image_id")
    private Long imageId;

    @Column(name = "image_url")
    private String imageUrl;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "order_index")
    private Integer orderIndex;
}
