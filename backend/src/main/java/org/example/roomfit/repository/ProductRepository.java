package org.example.roomfit.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.example.roomfit.domain.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository extends JpaRepository<Product, Long> {
    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.product_width, p.product_depth, p.product_height, i.image_url, p.model_url FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id AND i.order_index = 0  " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "WHERE p.product_width < :width " +
            "AND p.product_depth < :depth " +
            "AND p.product_height < :height " +
            "ORDER BY p.image_embedding <=> CAST(:queryVector AS vector) " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> findSimilarProducts(@Param("queryVector") String queryVector,
                                       @Param("limit") Integer limit,
                                       @Param("width") Float width,
                                       @Param("depth") Float depth,
                                       @Param("height") Float height);

    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.product_width, p.product_depth, p.product_height, i.image_url, p.model_url FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id AND i.order_index = 0  " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "WHERE c.category_id = :categoryId " +
            "AND p.product_width < :width " +
            "AND p.product_depth < :depth " +
            "AND p.product_height < :height " +
            "ORDER BY p.image_embedding <=> CAST(:queryVector AS vector) " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> findSimilarProducts(@Param("queryVector") String queryVector,
                                       @Param("limit") Integer limit,
                                       @Param("width") Float width,
                                       @Param("depth") Float depth,
                                       @Param("height") Float height,
                                       @Param("categoryId") Long categoryId);

    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.product_width, p.product_depth, p.product_height, i.image_url, p.model_url, " +
            "(1.0 - (p.image_embedding <=> CAST(:queryVector AS vector))) AS clip_score, " +
            "(1.0 / (1.0 + (p.color_vector_1 <-> CAST(:colorVector1 AS vector)))) AS color_score, " +
            "((0.6 * (1.0 - (p.image_embedding <=> CAST(:queryVector AS vector)))) + (0.4 * (1.0 / (1.0 + (p.color_vector_1 <-> CAST(:colorVector1 AS vector)))))) AS final_score " +
            "FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id AND i.order_index = 0  " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "WHERE c.category_id = :categoryId " +
            "AND p.product_width < :width " +
            "AND p.product_depth < :depth " +
            "AND p.product_height < :height " +
            "ORDER BY final_score DESC " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> findSimilarProductsWithColor(@Param("queryVector") String queryVector,
                                                @Param("limit") Integer limit,
                                                @Param("width") Float width,
                                                @Param("depth") Float depth,
                                                @Param("height") Float height,
                                                @Param("categoryId") Long categoryId,
                                                @Param("colorVector1") String colorVector1);


    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.product_width, p.product_depth, p.product_height, i.image_url, p.model_url, " +
            "(1.0 - (p.image_embedding <=> CAST(:queryVector AS vector))) AS clip_score, " +
            "(1.0 / (1.0 + (p.color_vector_1 <-> CAST(:colorVector1 AS vector)))) AS color_score, " +
            "((0.6 * (1.0 - (p.image_embedding <=> CAST(:queryVector AS vector)))) + (0.4 * (1.0 / (1.0 + (p.color_vector_1 <-> CAST(:colorVector1 AS vector)))))) AS final_score " +
            "FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id AND i.order_index = 0  " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "WHERE p.product_width < :width " +
            "AND p.product_depth < :depth " +
            "AND p.product_height < :height " +
            "ORDER BY final_score DESC " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> findSimilarProductsWithColor(@Param("queryVector") String queryVector,
                                                @Param("limit") Integer limit,
                                                @Param("width") Float width,
                                                @Param("depth") Float depth,
                                                @Param("height") Float height,
                                                @Param("colorVector1") String colorVector1);

    // 페이징 + 목록 조회
    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.created_at, i.image_url AS thumbnail_url, c.category_name " +
            "FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "INNER JOIN users u ON p.user_id = u.user_id " +
            "WHERE i.order_index = 0 " +
            "AND (:categoryId IS NULL OR p.category_id = :categoryId) " +
            "AND (:username IS NULL OR u.username = :username) " +
            "AND (:lastFetchedId IS NULL OR p.product_id < :lastFetchedId) " +
            "ORDER BY p.product_id DESC " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> findProducts(
            @Param("categoryId") Long categoryId,
            @Param("username") String username,
            @Param("lastFetchedId") Long lastFetchedId,
            @Param("limit") Integer limit);

    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.created_at, i.image_url AS thumbnail_url, c.category_name " +
            "FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "WHERE i.order_index = 0 " +
            "AND (:categoryId IS NULL OR p.category_id = :categoryId) " +
            "AND (:keyword IS NULL OR p.product_name ILIKE %:keyword%) " +
            "AND (:lastFetchedId IS NULL OR p.product_id < :lastFetchedId) " +
            "ORDER BY p.product_id DESC " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> searchProducts(
            @Param("categoryId") Long categoryId,
            @Param("lastFetchedId") Long lastFetchedId,
            @Param("limit") Integer limit,
            @Param("keyword") String keyword);

    // 상품 한 건 조회
    @Query(value = "SELECT p.product_id, p.user_id, u.nickname, p.product_name, p.product_price, p.description, p.product_width, p.product_depth, p.product_height, p.product_material, p.created_at, p.updated_at, c.category_id, c.category_name, u.image_url \n" +
            "FROM products p\n" +
            "INNER JOIN categories c ON p.category_id = c.category_id\n" +
            "inner join users u on u.user_id = p.user_id \n" +
            "WHERE p.product_id = :productId", nativeQuery = true)
    // Object -> 내부적으로 list로 받아서 List로 감싼 형태
    List<Object[]> findProductById(@Param("productId") Long productId);

    Optional<Product> findById(Long id);

    // ar 상품 목록 조회
    @Query(value = "select p.product_id, p.product_name, p.product_price, i.image_url, p.model_url\n" +
            "from products p \n" +
            "inner join imagefiles i on p.product_id = i.product_id\n" +
            "where i.order_index = 0\n" +
            "order by p.created_at desc", nativeQuery = true)
    List<Object[]> findAllForAr();

    // 특정 회원이 작성한 목록 조회
    @Query(value = "SELECT p.product_id, p.product_name, p.product_price, p.created_at, i.image_url AS thumbnail_url, c.category_name " +
            "FROM products p " +
            "INNER JOIN imagefiles i ON p.product_id = i.product_id " +
            "INNER JOIN categories c ON p.category_id = c.category_id " +
            "WHERE i.order_index = 0 " +
            "AND p.user_id = :userId " +
            "AND (:lastFetchedId IS NULL OR p.product_id < :lastFetchedId) " +
            "ORDER BY p.product_id DESC " +
            "LIMIT :limit", nativeQuery = true)
    List<Object[]> findProductsByUserId(
            @Param("userId") UUID userId,
            @Param("lastFetchedId") Long lastFetchedId,
            @Param("limit") Integer limit);

    // 비동기 재시도 대상 상품 조회
    // vision_status가 FAILED이고 재시도 횟수가 3회 미만이며
    // 마지막 시도 후 5분 이상 지난 상품
    @Query("SELECT p FROM Product p " +
            "WHERE p.visionStatus = 'FAILED' " +
            "AND p.visionRetryCount < 3 " +
            "AND (p.visionLastAttemptAt IS NULL OR p.visionLastAttemptAt < CURRENT_TIMESTAMP) " +
            "ORDER BY p.visionLastAttemptAt ASC NULLS FIRST")
    List<Product> findFailedVisionProducts();

    // 임베딩 또는 색상 데이터가 비어있는 상품 조회 (부분 재처리용)
    @Query("SELECT p FROM Product p " +
            "WHERE p.visionStatus = 'FAILED' " +
            "AND p.visionRetryCount < 3 " +
            "AND (p.imageEmbedding IS NULL OR (p.colorVector1 IS NULL AND p.colorVector2 IS NULL AND p.colorVector3 IS NULL))")
    List<Product> findIncompleteVisionProducts();

    @Query(value = "SELECT COUNT(p.product_id) FROM products p " +
            "WHERE p.product_width < :width " +
            "AND p.product_depth < :depth " +
            "AND p.product_height < :height", nativeQuery = true)
    int findProductsBySize(
            Float width,
            Float depth,
            Float height
    );
}
