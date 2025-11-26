package com.example.springbootapp.vo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
public class UserVO {
    private Long id;                // 出参用（用户ID）
    @NotBlank(message = "用户名不能为空")
    private String username;        // 入参必填（登录/注册）
    @NotBlank(message = "密码不能为空")
    private String password;        // 入参必填（登录/注册，后端加密）
    @NotBlank(message = "昵称不能为空")
    private String nickname;        // 入参必填（注册）
    @NotBlank(message = "专业不能为空")
    private String major;           // 入参必填（注册）
    @NotNull(message = "年级不能为空")
    private Integer grade;          // 入参必填（注册）
    private String interestTags;    // 可选（入参/出参）
    private String role;            // 出参用（角色）
    private String token;           // 出参用（登录令牌）
}