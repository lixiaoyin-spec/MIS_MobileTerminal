package com.example.springbootapp.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

import java.time.LocalDateTime;

@Data
public class PostVO {
    // 入参字段（发帖时必填）
    @NotBlank(message = "token不能为空")
    private String token;            // 身份令牌（用于获取当前用户）
    @NotBlank(message = "标题不能为空")
    private String title;            // 帖子标题
    @NotBlank(message = "内容不能为空")
    private String content;          // 帖子内容

    // 出参字段（返回帖子列表时包含）
    private Long id;                 // 帖子ID
    private String nickname;         // 发帖人昵称（冗余字段，避免联表查询）
    private LocalDateTime createTime; // 发帖时间
}