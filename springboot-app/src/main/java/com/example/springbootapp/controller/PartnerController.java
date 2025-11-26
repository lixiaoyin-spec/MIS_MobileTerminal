package com.example.springbootapp.controller;

import com.example.springbootapp.service.PartnerService;
import com.example.springbootapp.vo.PartnerVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import jakarta.validation.constraints.NotBlank;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/partner")
public class PartnerController {

    @Resource
    private PartnerService partnerService;

    // 学伴推荐接口（需传当前用户token，用于获取其标签）
    @GetMapping("/recommend")
    public Map<String, Object> recommend(
            @NotBlank(message = "token不能为空") @RequestParam String token) {

        List<PartnerVO> partnerList = partnerService.recommendPartners(token);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("msg", "推荐成功");
        result.put("data", partnerList);
        return result;
    }
}