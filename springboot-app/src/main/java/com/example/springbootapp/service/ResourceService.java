package com.example.springbootapp.service;

import com.example.springbootapp.vo.ResourceVO;
import org.springframework.web.multipart.MultipartFile;

public interface ResourceService {
    // 上传资源
    ResourceVO upload(MultipartFile file, String token);
}