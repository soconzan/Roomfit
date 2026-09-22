package org.example.roomfit.controller;

import java.util.List;
import java.util.NoSuchElementException;

import org.example.roomfit.domain.Product;
import org.example.roomfit.dto.CreateProduct;
import org.example.roomfit.dto.ProductARResponseDTO;
import org.example.roomfit.dto.ProductDetailResponseDTO;
import org.example.roomfit.dto.ProductListPageDTO;
import org.example.roomfit.dto.ProductModelResponseDTO;
import org.example.roomfit.dto.UpdateProduct;
import org.example.roomfit.response.ApiResponse;
import org.example.roomfit.service.ProductService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/products")
@AllArgsConstructor
@Slf4j
public class ProductController {

    private final ProductService productService;

    @PostMapping(value = "", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Product>> createProduct(@ModelAttribute CreateProduct createProduct) {
        log.info("createProduct called");
        try {
            System.out.println("Received product data: " + createProduct.toString()); // 시스템 로그(콘솔)에 수신된 데이터 출력
            productService.saveProduct(createProduct);
            return ResponseEntity.ok(new ApiResponse<>(true, "Received product data: " + createProduct.toString(), null));
        } catch (Exception e) {
            e.printStackTrace(); // 시스템 로그(콘솔)에 에러 스택 트레이스 강제 출력
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false,  e.getMessage(), null));
        }
    }

    @PatchMapping(value = "/{productId}", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Product>> updateProduct(
            @PathVariable Long productId,
            @ModelAttribute UpdateProduct updateProduct,
            @AuthenticationPrincipal User userDetails
    ) {
        log.info("updateProduct called");
        if (userDetails == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "인증이 필요합니다.", null));
        }

        try {
            Product updatedProduct = productService.updateProduct(updateProduct);
            return ResponseEntity.ok(new ApiResponse<>(true, "상품 업데이트 성공", updatedProduct));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    // http://localhost:8080/api/products?categoryId=3 -> 단건 조회랑 구분하기 위해 RequestParam으로 설정
    @GetMapping("")
    public ResponseEntity<ApiResponse<ProductListPageDTO>> getProducts(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Long lastFetchedId,
            @RequestParam(required = false, defaultValue = "10") Integer limit)
    {
        log.info("getProducts called");
        try{
            ProductListPageDTO result = productService.getProducts(categoryId, username, lastFetchedId, limit);
            return ResponseEntity.ok(new ApiResponse<>(true, "상품 목록 조회 성공", result));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<ProductListPageDTO>> searchProducts(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long lastFetchedId,
            @RequestParam(required = false, defaultValue = "10") Integer limit,
            @RequestParam(required = false) String keyword
    ) {
        log.info("searchProducts called");
        try {
            ProductListPageDTO result = productService.searchProducts(categoryId, lastFetchedId, limit, keyword);
            return ResponseEntity.ok(new ApiResponse<>(true, "상품 검색 성공", result));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<ProductListPageDTO>> getMyProducts(
            @RequestParam(required = false) Long lastFetchedId,
            @RequestParam(required = false, defaultValue = "10") Integer limit,
            @AuthenticationPrincipal User userDetails)
    {
        log.info("getMyProducts called");
        if (userDetails == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "인증이 필요합니다.", null));
        }

        try {
            ProductListPageDTO result = productService.getProducts(null, userDetails.getUsername(), lastFetchedId, limit);
            return ResponseEntity.ok(new ApiResponse<>(true, "내 상품 목록 조회 성공", result));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    @GetMapping("/{productId}")
    public ResponseEntity<ApiResponse<ProductDetailResponseDTO>> getProduct(@PathVariable Long productId) {
        log.info("getProduct called");
        try {
            ProductDetailResponseDTO productDetailResponseDTO = productService.getProduct(productId);
            return ResponseEntity.ok(new ApiResponse<>(true, "상품 한 건 조회 성공", productDetailResponseDTO));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }

    @GetMapping("/{productId}/model")
    public ResponseEntity<ApiResponse<ProductModelResponseDTO>> getProductModel(@PathVariable Long productId) {
        log.info("getProductModel called");
        try {
            ProductModelResponseDTO productModelResponseDTO = productService.getProductModel(productId);
            return ResponseEntity.ok(new ApiResponse<>(true, "상품 모델 조회 성공", productModelResponseDTO));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }


    @GetMapping("/ar")
    public ResponseEntity<ApiResponse<List<ProductARResponseDTO>>> getARProducts()
    {
        log.info("getARProducts called");
        try{
            List<ProductARResponseDTO> productARResponseDTO = productService.getARProducts();
            return ResponseEntity.ok(new ApiResponse<>(true, "AR 상품 목록조회 성공", productARResponseDTO));
        }catch (Exception e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }


    @DeleteMapping("/{productId}")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(
            @PathVariable Long productId,
            @AuthenticationPrincipal User userDetails
    ) {
        log.info("deleteProduct called");
        if (userDetails == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse<>(false, "인증이 필요합니다.", null));
        }

        try {
            productService.deleteProduct(productId, userDetails.getUsername());
            return ResponseEntity.ok(new ApiResponse<>(true, "상품 삭제 성공", null));
        } catch (NoSuchElementException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        } catch (SecurityException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, e.getMessage(), null));
        }
    }
}
