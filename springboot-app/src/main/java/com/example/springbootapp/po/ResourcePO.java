package com.example.springbootapp.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("resource") // 数据库表名不变，仍为resource
public class ResourcePO { // 类名修改：Resource → ResourcePO
    @TableId(type = IdType.AUTO)
    private Long id;                 // 资源ID
    private Long userId;             // 上传者ID（关联user表）
    private String filename;         // 原始文件名（如"笔记.pdf"）
    private String fileSuffix;       // 文件后缀（如"pdf"）
    private String filePath;         // 服务器存储路径（如"/upload/123.pdf"）
    private String fileUrl;          // 访问URL（如"http://localhost:8080/upload/123.pdf"）
    private Long fileSize;           // 文件大小（字节）
    private LocalDateTime createTime; // 上传时间
}