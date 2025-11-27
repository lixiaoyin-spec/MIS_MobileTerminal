package com.example.springbootapp.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class PostDetailVO {
    // 帖子信息
    private Long id;                    // 帖子ID
    private String title;               // 帖子标题
    private String content;             // 帖子内容
    private String nickname;            // 发帖人昵称
    private Integer viewCount;          // 浏览量
    private LocalDateTime createTime;   // 发帖时间
    private LocalDateTime updateTime;   // 更新时间

    // 评论列表
    private List<CommentVO> comments;   // 该帖子下的所有评论
}

