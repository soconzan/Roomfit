package org.example.roomfit.service;

import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.stream.Collectors;

import org.example.roomfit.domain.ImageFile;
import org.example.roomfit.domain.Product;
import org.example.roomfit.domain.VisionStatus;
import org.example.roomfit.dto.CreateProduct;
import org.example.roomfit.dto.ProductARResponseDTO;
import org.example.roomfit.dto.ProductDetailResponseDTO;
import org.example.roomfit.dto.ProductListPageDTO;
import org.example.roomfit.dto.ProductListResponseDTO;
import org.example.roomfit.dto.ProductModelResponseDTO;
import org.example.roomfit.dto.UpdateProduct;
import org.example.roomfit.repository.CategoryRepository;
import org.example.roomfit.repository.ImageFileRepository;
import org.example.roomfit.repository.ProductRepository;
import org.example.roomfit.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@AllArgsConstructor
@Service
@Slf4j
public class ProductService {

    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final VisionServiceClient visionServiceClient;
    private final R2Service r2Service;
    private final ImageFileRepository imageFileRepository;
    private final FastApiService fastApiService;
    private final FcmService fcmService;
    private final ProductVisionService productVisionService;
    private final ModelService modelService;

    @Transactional
    public Product saveProduct(CreateProduct createProduct) {

        // DTO에서 엔티티로 변환
        log.info("User ID 확인: {}", createProduct.getUserId());
        Product productEntity = new Product();
        productEntity.setUser(userRepository.findById(createProduct.getUserId()).orElseThrow());
        log.info("User ID로 조회된 User ID: {}", productEntity.getUser().getUserId());
        productEntity.setCategory(categoryRepository.findById(createProduct.getCategoryId()).orElseThrow());
        productEntity.setProductName(createProduct.getProductName());
        productEntity.setProductPrice(createProduct.getProductPrice());
        productEntity.setDescription(createProduct.getDescription());
        productEntity.setProductWidth(createProduct.getProductWidth());
        productEntity.setProductDepth(createProduct.getProductDepth());
        productEntity.setProductHeight(createProduct.getProductHeight());
        productEntity.setProductMaterial(createProduct.getProductMaterial());
        log.info("Product 엔티티로 변환 완료: {}", productEntity);

        // 비전 처리 상태 초기화
        productEntity.setVisionStatus(VisionStatus.PENDING.getValue());
        productEntity.setVisionRetryCount(0);

        // Product 엔티티 저장
        Product savedProduct = productRepository.save(productEntity);
        log.info("Product 엔티티 저장 완료: {}", savedProduct);

        // 이미지 파일 저장
        for (int i = 0; i < createProduct.getImages().size(); i++) {
            MultipartFile image = createProduct.getImages().get(i);
            String imageUrl = r2Service.uploadFile(image, "images");
            ImageFile imageFileEntity = new ImageFile();
            imageFileEntity.setProduct(savedProduct);
            imageFileEntity.setImageUrl(imageUrl);
            imageFileEntity.setOrderIndex(i);
            imageFileRepository.save(imageFileEntity);
        }
        log.info("이미지 파일 저장 완료: {} files", createProduct.getImages().size());

        // 썸네일 이미지의 배경 제거 및 비전 처리 비동기 실행
        MultipartFile thumbnailImage = createProduct.getImages().get(0);
        byte[] thumbnailBytes = extractBytes(thumbnailImage);
        String thumbnailFilename = thumbnailImage.getOriginalFilename();
        productVisionService.processImageAsync(savedProduct.getId(), thumbnailBytes, thumbnailFilename);

        
        // 3D 모델 비동기 생성 요청
        modelService.processModel(
            createProduct.getFrontImage() != null ? extractBytes(createProduct.getFrontImage()) : null,
            createProduct.getLeftImage() != null ? extractBytes(createProduct.getLeftImage()) : null,
            createProduct.getRightImage() != null ? extractBytes(createProduct.getRightImage()) : null,
            createProduct.getBackImage() != null ? extractBytes(createProduct.getBackImage()) : null,
            savedProduct.getId(),
            savedProduct);

        return savedProduct;
    }

    private String cutString(String input, int maxLength) {
        if (input == null) return null;
        return input.length() <= maxLength ? input : input.substring(0, maxLength) + "...";
    }

    /**
     * MultipartFile의 바이트 배열 추출
     * 비동기 작업에 안전하게 전달하기 위함
     */
    private byte[] extractBytes(MultipartFile file) {
        try {
            return file.getBytes();
        } catch (Exception e) {
            log.error("파일 바이트 추출 실패: {}", e.getMessage(), e);
            throw new RuntimeException("파일 처리 실패", e);
        }
    }

    // 목록조회
    public ProductListPageDTO getProducts(Long categoryId, String username, Long lastFetchedId, int limit) {
        List<Object[]> results = productRepository.findProducts(categoryId, username, lastFetchedId, limit + 1);

        return toProductListPageDTO(results, limit);
    }

    // 내가 작성한 상품 목록 조회
    public ProductListPageDTO getMyProducts(UUID userId, Long lastFetchedId, int limit) {
        List<Object[]> results = productRepository.findProductsByUserId(userId, lastFetchedId, limit + 1);

        return toProductListPageDTO(results, limit);
    }

    private ProductListPageDTO toProductListPageDTO(List<Object[]> results, int limit) {
        boolean hasNext = results.size() > limit;
        if (hasNext) results = results.subList(0, limit);

        List<ProductListResponseDTO> products = results.stream()
                .map(p -> new ProductListResponseDTO(
                        (Long) p[0],
                        (String) p[1],
                        (Long) p[2],
                        ((Instant) p[3]).atOffset(ZoneOffset.UTC),
                        (String) p[4],
                        (String) p[5]
                )).collect(Collectors.toList());

        Long nextCursor = hasNext ? (Long) results.get(results.size() - 1)[0] : null;

        return new ProductListPageDTO(products, nextCursor, hasNext);
    }

    public ProductListPageDTO searchProducts(Long categoryId, Long lastFetchedId, int limit, String keyword) {
        List<Object[]> results = productRepository.searchProducts(categoryId, lastFetchedId, limit + 1, keyword);

        boolean hasNext = results.size() > limit;
        if (hasNext) results = results.subList(0, limit);

        List<ProductListResponseDTO> products = results.stream()
                .map(p -> new ProductListResponseDTO(
                        (Long) p[0],
                        (String) p[1],
                        (Long) p[2],
                        ((Instant) p[3]).atOffset(ZoneOffset.UTC),
                        (String) p[4],
                        (String) p[5]
                )).collect(Collectors.toList());

        Long nextCursor = hasNext ? (Long) results.get(results.size() - 1)[0] : null;

        return new ProductListPageDTO(products, nextCursor, hasNext);
    }

    // 단건 조회
    public ProductDetailResponseDTO getProduct(Long productId)
    {
        Object[] p = productRepository.findProductById(productId).getFirst();
        List<String> imageUrls = imageFileRepository.findImageUrlsByProductId(productId);

        return new ProductDetailResponseDTO(
                (Long) p[0],                                        // productId
                (UUID) p[1],                                        // userId
                (String) p[2],                                      // userName
                (String) p[3],                                      // productName
                (Long) p[12],                                       // categoryId
                (String) p[13],                                     // categoryName
                (Long) p[4],                                        // productPrice
                (String) p[5],                                      // description
                (Double) p[6],                                      // productWidth
                (Double) p[7],                                      // productDepth
                (Double) p[8],                                      // productHeight
                (String) p[9],                                     // material
                ((Instant) p[10]).atOffset(ZoneOffset.UTC),          // createdAt
                ((Instant) p[11]).atOffset(ZoneOffset.UTC),          // updatedAt
                imageUrls,
                (String) p[14]
        );
    }

    // ar 호출 목록 조회
    public List<ProductARResponseDTO> getARProducts()
    {
        List<Object[]> results = productRepository.findAllForAr();

        return results.stream()
                .map(p -> new ProductARResponseDTO(
                        (Long) p[0],
                        (String) p[1],
                        (Long) p[2],
                        (String) p[3],
                        (String) p[4]
                )).collect(Collectors.toList());
    }

    // 단건 상품 모델 조회
    public ProductModelResponseDTO getProductModel(Long productId) {
        Product p = productRepository.findById(productId)
                .orElseThrow(() -> new NoSuchElementException("상품을 찾을 수 없습니다."));

        return new ProductModelResponseDTO(
                p.getId(),
                p.getModelUrl()
        );
    }

    @Transactional
    public void deleteProduct(Long productId, String username) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new NoSuchElementException("상품을 찾을 수 없습니다."));

        if (product.getUser() == null || !product.getUser().getUsername().equals(username)) {
            throw new SecurityException("본인이 작성한 상품만 삭제할 수 있습니다.");
        }

        List<ImageFile> imageFiles = imageFileRepository.findByProduct_Id(productId);
        for (ImageFile imageFile : imageFiles) {
            r2Service.deleteFile(imageFile.getImageUrl());
        }

        imageFileRepository.deleteAll(imageFiles);
        productRepository.delete(product);
    }

    public Product updateProduct(UpdateProduct updateProduct) {
        Product product = productRepository.findById(updateProduct.getProductId()).orElseThrow(() -> new NoSuchElementException("상품을 찾을 수 없습니다."));
        
        // DTO에서 엔티티로 변환
        Product productEntity = new Product();
        productEntity.setUser(userRepository.findById(updateProduct.getUserId()).orElseThrow());
        productEntity.setCategory(categoryRepository.findById(updateProduct.getCategoryId()).orElseThrow());
        productEntity.setProductName(updateProduct.getProductName());
        productEntity.setProductPrice(updateProduct.getProductPrice());
        productEntity.setDescription(updateProduct.getDescription());
        productEntity.setProductWidth(updateProduct.getProductWidth());
        productEntity.setProductDepth(updateProduct.getProductDepth());
        productEntity.setProductHeight(updateProduct.getProductHeight());
        productEntity.setProductMaterial(updateProduct.getProductMaterial());
        log.info("Product 엔티티로 변환 완료: {}", productEntity);

        Product savedProduct = productRepository.save(productEntity);
        log.info("Product 엔티티 저장 완료: {}", savedProduct);
        // 3D 모델 비동기 생성 요청
        modelService.processModel(
            updateProduct.getFrontImage() != null ? extractBytes(updateProduct.getFrontImage()) : null,
            updateProduct.getLeftImage() != null ? extractBytes(updateProduct.getLeftImage()) : null,
            updateProduct.getRightImage() != null ? extractBytes(updateProduct.getRightImage()) : null,
            updateProduct.getBackImage() != null ? extractBytes(updateProduct.getBackImage()) : null,
            savedProduct.getId(),
            savedProduct);
        log.info("3D 모델 비동기 생성 요청 완료");
        return null;
    };
}
