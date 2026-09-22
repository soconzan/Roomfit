package org.example.roomfit.service;

import lombok.RequiredArgsConstructor;
import org.example.roomfit.dto.CategoryResponseDTO;
import org.example.roomfit.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryResponseDTO> getAllCategories(){
        return categoryRepository.findAll()
                .stream().map(c -> new CategoryResponseDTO(c.getCategoryId(), c.getCategoryName()))
                .collect(Collectors.toList());
    }
}
