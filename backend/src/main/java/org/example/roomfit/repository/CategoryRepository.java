package org.example.roomfit.repository;

import java.util.List;

import org.example.roomfit.domain.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findAll();

    @Query(value = "SELECT * FROM categories ORDER BY embedding <=> CAST(:queryVector AS vector) LIMIT 1", nativeQuery = true)
    Category findSimilarCategory(@Param("queryVector") String queryVector);

    Category findByCategoryName(String category);
}
