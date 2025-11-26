package com.example.springbootapp.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

@Data
public class CommentVO {
    // 入参字段（评论时必填）
    @NotNull(message = "帖子ID不能为空")
    private Long postId;             // 被评论的帖子ID
    @NotBlank(message = "评论内容不能为空")
    private String content;          // 评论内容
    @NotBlank(message = "token不能为空")
    private String token;            // 身份令牌（用于获取当前用户）

    // 出参字段（返回评论列表时包含，可选）
    private Long id;                 // 评论ID
    private String nickname;         // 评论人昵称
    private LocalDateTime createTime; // 评论时间
}