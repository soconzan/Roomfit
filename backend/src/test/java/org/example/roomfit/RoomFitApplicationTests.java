package org.example.roomfit;

import org.example.roomfit.dto.ProductListPageDTO;
import org.example.roomfit.service.ProductService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.example.roomfit.service.FastApiService;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;


import static org.junit.jupiter.api.Assertions.*;

@TestPropertySource(properties = {
        "spring.jpa.show-sql=true",
        "logging.level.org.hibernate.SQL=DEBUG",
        "logging.level.org.hibernate.type.descriptor.sql=TRACE"
})

@SpringBootTest
@Transactional
class RoomFitApplicationTests {


    @Autowired
    private FastApiService fastApiService;

    @Autowired
    private ProductService productService;

    @Test
    void contextLoads() {
        System.out.println("Application context loaded successfully.");
    }

    @Test
    void testSearchProducts() {
        ProductListPageDTO result = productService.searchProducts(8L, null, 10, "chair");
        assertNotNull(result);
        assertTrue(result.getProduct().size() <= 10);
        System.out.println("Search Products Result: " + result.getProduct().size() + " products found.");
        System.out.println("Has Next: " + result.isHasNext());
        for(var product : result.getProduct()) {
            System.out.println("Product ID: " + product.getProductId() + ", Name: " + product.getProductName());
        }
    }

    @Test
    void testFindProducts() {
        ProductListPageDTO result = productService.getProducts(1L, null, null, 10);
        assertNotNull(result);
        assertTrue(result.getProduct().size() <= 10);
        System.out.println("Find Products Result: " + result.getProduct().size() + " products found.");
        System.out.println("Has Next: " + result.isHasNext());
        for(var product : result.getProduct()) {
            System.out.println("Product ID: " + product.getProductId() + ", Name: " + product.getProductName());
        }
    }

}
