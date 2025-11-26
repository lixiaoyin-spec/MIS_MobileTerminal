package com.example.springbootapp.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("post") // 对应数据库post表
public class Post {
    @TableId(type = IdType.AUTO)
    private Long id;                 // 帖子ID
    private Long userId;             // 发帖人ID（关联user表id）
    private String title;            // 帖子标题
    private String content;          // 帖子内容
    private Integer viewCount;       // 浏览量（默认0）
    private LocalDateTime createTime; // 创建时间
    private LocalDateTime updateTime; // 更新时间
}