package com.example.springbootapp.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class ClockVO {
    // 入参字段（打卡时必填）
    @NotBlank(message = "打卡内容不能为空")
    private String content;          // 打卡内容
    @NotBlank(message = "token不能为空")
    private String token;            // 身份令牌（获取当前用户）

    // 出参字段（打卡列表返回用）
    private Long id;                 // 打卡ID
    private String nickname;         // 打卡人昵称（非当前用户时也能显示）
    private LocalDate clockDate;     // 打卡日期
    private LocalDateTime createTime; // 打卡时间
}