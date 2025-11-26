package com.example.springbootapp.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("clock") // 对应数据库clock表
public class Clock {
    @TableId(type = IdType.AUTO)
    private Long id;                 // 打卡ID
    private Long userId;             // 打卡用户ID（关联user表）
    private String content;          // 打卡内容（如"今日学习Java集合框架"）
    private LocalDate clockDate;     // 打卡日期（用于判断是否重复打卡）
    private LocalDateTime createTime; // 打卡时间（精确到时分秒）
}