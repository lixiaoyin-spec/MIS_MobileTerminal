package com.example.springbootapp.controller;

import com.example.springbootapp.service.ResourceService;
import com.example.springbootapp.vo.ResourceVO;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.Resource;
import jakarta.validation.constraints.NotBlank;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/resource")
public class ResourceController {

    @Resource
    private ResourceService resourceService;

    // 资源上传接口（multipart/form-data格式）
    @PostMapping("/upload")
    public Map<String, Object> upload(
            @RequestParam("file") MultipartFile file,
            @NotBlank(message = "token不能为空") @RequestParam("token") String token) {

        ResourceVO result = resourceService.upload(file, token);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("msg", "上传成功");
        response.put("data", result.getFileUrl()); // 直接返回fileUrl
        return response;
    }
}