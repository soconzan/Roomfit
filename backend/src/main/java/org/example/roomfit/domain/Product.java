package org.example.roomfit.domain;

import java.time.OffsetDateTime;

import org.hibernate.annotations.ColumnTransformer;
import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Entity
@Table(name="products")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "product_price")
    private Long productPrice;

    @Column(columnDefinition = "Text", name = "description")
    private String description;

    @CreationTimestamp
    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    @CreationTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Column(name = "style")
    private String style;

    @Column(columnDefinition = "vector(768)", name = "image_embedding")
    @ColumnTransformer(write = "CAST(? AS vector)")
    private String imageEmbedding;

    @Column(columnDefinition = "vector(3)", name = "color_vector_1")
    @ColumnTransformer(write = "CAST(? AS vector)")
    private String colorVector1;

    @Column(columnDefinition = "vector(3)", name = "color_vector_2")
    @ColumnTransformer(write = "CAST(? AS vector)")
    private String colorVector2;

    @Column(columnDefinition = "vector(3)", name = "color_vector_3")
    @ColumnTransformer(write = "CAST(? AS vector)")
    private String colorVector3;

    @Column(name = "product_width")
    private float productWidth;

    @Column(name = "product_depth")
    private float productDepth;

    @Column(name = "product_height")
    private float productHeight;

    @Column(name = "product_material")
    private String productMaterial;

    @Column(name = "product_image_front_url")
    private String productImageFrontUrl;

    @Column(name = "product_image_left_url")
    private String productImageLeftUrl;

    @Column(name = "product_image_right_url")
    private String productImageRightUrl;

    @Column(name = "product_image_back_url")
    private String productImageBackUrl;
    
    @Column(name = "model_url")
    private String modelUrl;

    @Column(name = "vision_status")
    private String visionStatus;

    @Column(name = "vision_retry_count")
    private Integer visionRetryCount;

    @Column(name = "vision_last_attempt_at")
    private OffsetDateTime visionLastAttemptAt;

    @Column(name = "vision_error_message", columnDefinition = "text")
    private String visionErrorMessage;
}
