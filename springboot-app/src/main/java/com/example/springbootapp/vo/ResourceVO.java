package com.example.springbootapp.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

@Data
public class ResourceVO {
    // 入参：上传时需要token验证身份
    @NotBlank(message = "token不能为空")
    private String token;            // 身份令牌

    // 出参：返回文件访问URL
    private String fileUrl;          // 上传成功后返回的文件URL
}