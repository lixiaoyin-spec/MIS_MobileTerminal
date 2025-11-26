package com.example.springbootapp.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user") // 对应数据库user表
public class User {
    @TableId(type = IdType.AUTO) // 自增主键
    private Long id;                // 用户ID
    private String username;        // 登录名（手机号/邮箱）
    private String password;        // 加密密码
    private String nickname;        // 昵称
    private String major;           // 专业
    private Integer grade;          // 年级
    private String interestTags;    // 兴趣标签（逗号分隔）
    private String role;            // 角色（STUDENT/TEACHER）
    private Integer status;         // 状态（0禁用/1正常）
    private LocalDateTime createTime; // 创建时间
    private LocalDateTime updateTime; // 更新时间
}