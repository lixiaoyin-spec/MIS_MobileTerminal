package com.example.springbootapp.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("comment") // 对应数据库comment表
public class Comment {
    @TableId(type = IdType.AUTO)
    private Long id;                 // 评论ID
    private Long postId;             // 关联帖子ID（对应post表id）
    private Long userId;             // 评论人ID（关联user表id）
    private String content;          // 评论内容
    private LocalDateTime createTime; // 评论时间
}