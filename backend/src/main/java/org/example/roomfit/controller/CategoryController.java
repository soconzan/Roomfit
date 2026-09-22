package org.example.roomfit.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.dto.CategoryResponseDTO;
import org.example.roomfit.response.ApiResponse;
import org.example.roomfit.service.CategoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@RequestMapping("/api/categories")
@Controller
@RequiredArgsConstructor
@Slf4j
public class CategoryController {

    private final CategoryService categoryService;

    // 카테고리 전체 조회
    @GetMapping("")
    public ResponseEntity<ApiResponse<List<CategoryResponseDTO>>> getAllCategory()
    {
        log.info("Get all categories request received");
        return ResponseEntity.ok(new ApiResponse<>(true, null, categoryService.getAllCategories()));
    }
}
