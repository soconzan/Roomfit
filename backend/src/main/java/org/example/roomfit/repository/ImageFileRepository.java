package org.example.roomfit.repository;

import org.example.roomfit.domain.ImageFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ImageFileRepository extends JpaRepository<ImageFile, Long> {
    @Query(value = "SELECT image_url FROM imagefiles WHERE product_id = :productId ORDER BY order_index", nativeQuery = true)
    List<String> findImageUrlsByProductId(@Param("productId") Long productId);

    List<ImageFile> findByProduct_Id(Long productId);

    // 특정 순서의 이미지 조회 (썸네일: order_index = 0)
    ImageFile findByProduct_IdAndOrderIndex(Long productId, Integer orderIndex);
}
